
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "Command-line interface for RESTful web services",
  "AUTHOR" => "Brian Phillips <bphillips\@cpan.org>",
  "BUILD_REQUIRES" => {
    "File::Basename" => 0,
    "File::Find" => 0,
    "File::Temp" => 0,
    "HTTP::Headers" => 0,
    "Test::MockObject" => 0,
    "Test::More" => 0
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "App-Presto",
  "EXE_FILES" => [
    "bin/presto"
  ],
  "LICENSE" => "perl",
  "NAME" => "App::Presto",
  "PREREQ_PM" => {
    "Data::DPath" => 0,
    "Data::Dump" => 0,
    "Data::Dumper" => 0,
    "File::HomeDir" => 0,
    "File::Path" => "2.08",
    "JSON" => 0,
    "MIME::Base64" => 0,
    "Module::Pluggable" => 0,
    "Moo" => 0,
    "Moo::Role" => 0,
    "REST::Client" => 0,
    "Regexp::Common" => 0,
    "Scalar::Util" => 0,
    "Term::ShellUI" => 0,
    "URI" => 0,
    "URI::QueryParam" => 0,
    "YAML" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "VERSION" => "0.004",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



