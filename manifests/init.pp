class jekyll-site(
                $target_dir = '/var/www/jekyll-site',
                $repo_url = 'https://github.com/benschw/txt.fliglio.com.git,
                $branch = 'master',
                $app_name = 'my-app'
        ) {

        exec { 'clone-site':
                command     => "git clone -b $branch $repo_url $target_dir",
                user        => "www-data",
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


        service { 'myapp':
                ensure => running,
                provider => 'upstart',
                require => [
                        File["upstart-${app_name}"],
                        Exec['clone-site']
                ]
        }

}


