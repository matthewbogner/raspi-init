class build() {

	Exec { path => [ '/bin/', '/sbin/' , '/usr/bin/', '/usr/sbin/' ] }

	package { 'unzip':
	  ensure => present,
	}
    ->
    package { 'parted':
      ensure => present,
    }
	->
    package { 'man':
      ensure => present,
    }
}