package # hide from PAUSE
    TestSchema::Result::Artist;

use warnings;
use strict;

use base qw(DBIx::Class::Core);

__PACKAGE__->table('artist');
__PACKAGE__->add_columns(
  'artistid' => {
    data_type => 'integer',
    is_auto_increment => 1,
  },
  'name' => {
    data_type => 'varchar',
    size      => 100,
    is_nullable => 1,
  },
  rank => {
    data_type => 'integer',
    default_value => 13,
  },
  charfield => {
    data_type => 'char',
    size => 10,
    is_nullable => 1,
  },
);
__PACKAGE__->set_primary_key('artistid');
__PACKAGE__->add_unique_constraint(['name']);
__PACKAGE__->add_unique_constraint(artist => ['artistid']); # do not remove, part of a test
__PACKAGE__->add_unique_constraint(u_nullable => [qw/charfield rank/]);


__PACKAGE__->mk_classdata('field_name_for', {
    artistid    => 'primary key',
    name        => 'artist name',
});

# the undef condition in this rel is *deliberate*
# tests oddball legacy syntax
__PACKAGE__->has_many(
    cds => 'TestSchema::Result::CD', undef,
    { order_by => { -asc => 'year'} },
);

__PACKAGE__->has_many(
  cds_cref_cond => 'TestSchema::Result::CD',
  sub {
    # This is for test purposes only. A regular user does not
    # need to sanity check the passed-in arguments, this is what
    # the tests are for :)
    my $args = &check_customcond_args;

    return (
      { "$args->{foreign_alias}.artist" => { '=' => { -ident => "$args->{self_alias}.artistid"} },
      },
      $args->{self_resultobj} && {
        "$args->{foreign_alias}.artist" => $args->{self_resultobj}->artistid,
      }
    );
  },
);

__PACKAGE__->has_many(
  cds_80s => 'TestSchema::Result::CD',
  sub {
    # This is for test purposes only. A regular user does not
    # need to sanity check the passed-in arguments, this is what
    # the tests are for :)
    my $args = &check_customcond_args;

    return (
      { "$args->{foreign_alias}.artist" => { '=' => \ "$args->{self_alias}.artistid" },
        "$args->{foreign_alias}.year"   => { '>' => 1979, '<' => 1990 },
      },
      $args->{self_resultobj} && {
        "$args->{foreign_alias}.artist" => { '=' => \[ '?',  $args->{self_resultobj}->artistid ] },
        "$args->{foreign_alias}.year"   => { '>' => 1979, '<' => 1990 },
      }
    );
  },
);


__PACKAGE__->has_many(
  cds_84 => 'TestSchema::Result::CD',
  sub {
    # This is for test purposes only. A regular user does not
    # need to sanity check the passed-in arguments, this is what
    # the tests are for :)
    my $args = &check_customcond_args;

    return (
      { "$args->{foreign_alias}.artist" => { -ident => "$args->{self_alias}.artistid" },
        "$args->{foreign_alias}.year"   => 1984,
      },
      $args->{self_resultobj} && {
        "$args->{foreign_alias}.artist" => $args->{self_resultobj}->artistid,
        "$args->{foreign_alias}.year"   => 1984,
      }
    );
  }
);


__PACKAGE__->has_many(
  cds_90s => 'TestSchema::Result::CD',
  sub {
    # This is for test purposes only. A regular user does not
    # need to sanity check the passed-in arguments, this is what
    # the tests are for :)
    my $args = &check_customcond_args;

    return (
      { "$args->{foreign_alias}.artist" => { -ident => "$args->{self_alias}.artistid" },
        "$args->{foreign_alias}.year"   => { '>' => 1989, '<' => 2000 },
      }
    );
  }
);


__PACKAGE__->has_many(
    cds_unordered => 'TestSchema::Result::CD'
);
__PACKAGE__->has_many(
    cds_very_very_very_long_relationship_name => 'TestSchema::Result::CD'
);


__PACKAGE__->has_many(
    cds_without_genre => 'TestSchema::Result::CD',
    sub {
        # This is for test purposes only. A regular user does not
        # need to sanity check the passed-in arguments, this is what
        # the tests are for :)
        my $args = &check_customcond_args;

        return (
          {
            "$args->{foreign_alias}.artist" => { -ident => "$args->{self_alias}.artistid" },
            "$args->{foreign_alias}.genreid" => undef,
          }, $args->{self_resultobj} && {
            "$args->{foreign_alias}.artist" => $args->{self_resultobj}->artistid,
            "$args->{foreign_alias}.genreid" => undef,
          }
        ),
    },
);

sub sqlt_deploy_hook {
  my ($self, $sqlt_table) = @_;

  if ($sqlt_table->schema->translator->producer_type =~ /SQLite$/ ) {
    $sqlt_table->add_index( name => 'artist_name_hookidx', fields => ['name'] )
      or die $sqlt_table->error;
  }
}

sub store_column {
  my ($self, $name, $value) = @_;
  $value = 'X '.$value if ($name eq 'name' && $value && $value =~ /(X )?store_column test/);
  $self->next::method($name, $value);
}


1;