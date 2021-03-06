class jekyll-site(
                $target_dir = '/var/www/jekyll-site',
                $repo_url = 'https://github.com/benschw/txt.fliglio.com.git',
                $branch = 'master',
                $app_name = 'my-app',
                $port = '80',
        ) {


        package { ['rubygems', 'git']:
                ensure => present,
        }
        package { 'jekyll':
                ensure   => 'installed',
                provider => 'gem',
                require     => [
                        Package['rubygems'],
                ],
        }

        exec { 'clone-site':
                command     => "git clone -b $branch $repo_url $target_dir",
                require     => [
                        Package['git'],
                ],
                creates     => "$target_dir/docker-selenium-grid",
        }

        file { "upstart-${app_name}":
                path    => "/etc/init/${app_name}.conf",
                owner   => 'root',
                group   => 'root',
                mode    => '0644',
                content => template('jekyll-site/upstart.erb'),
        }


        service { "${app_name}":
                ensure => running,
                provider => 'upstart',
                require => [
                        File["upstart-${app_name}"],
                        Exec['clone-site'],
                        Package['jekyll'],
                ]
        }

}


