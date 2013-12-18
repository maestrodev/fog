Shindo.tests("Fog::Compute[:google] | servers", ['google']) do

  @zone = 'us-central1-a'
  @disk = @google.disks.create({
    :name => "fogservername",
    :size_gb => 2,
    :zone_name => @zone,
    :source_image => "debian-7-wheezy-v20131120",
  }
  @disk.wait_for { disk.ready? }

  collection_tests(Fog::Compute[:google].servers, {:name => 'fogservername', :zone_name => @zone, :machine_type => 'n1-standard-1', :disks => [disk]})

end
