package t::helper;

sub exec_sql_stmts_in_file {

  my $dbh      = shift;
  my $filename = shift;

  open (my $sql, '<', $filename) or die "Could not open $filename";
  
  while (my $stmt = <$sql>) {
    chomp $stmt;
    $stmt =~ s/--.*//;
    next unless $stmt =~ /\S/;
    print "$stmt\n";
    $dbh->do($stmt) or die "Could not execute $stmt";
  }
  
  
  close $sql;
}

1;
