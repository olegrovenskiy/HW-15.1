terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = "xxxxxxxxxxxxx"
  cloud_id  = "cloud-orovenskiy"
  folder_id = "xxxxxxxxxxxxxxx"
  zone      = "ru-central1-a"
}

resource "yandex_compute_instance" "vm-1" {
  name = "nat-instance"


  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    ip_address = "192.168.10.254"
    nat       = true
  }

  metadata = {
    user-data = "${file("meta.txt")}"
  }


}

resource "yandex_compute_instance" "vm-2" {
  name = "test-1"


  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8mn5e1cksb3s1pcq12"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = false

  }

  metadata = {
    user-data = "${file("meta.txt")}"
  }

}

resource "yandex_compute_instance" "vm-0" {
  name = "test-0"


  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd8mn5e1cksb3s1pcq12"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-1.id
    nat       = true

  }

  metadata = {
    user-data = "${file("meta.txt")}"
  }

}


resource "yandex_vpc_network" "network-1" {
  name = "network1"
}
resource "yandex_vpc_route_table" "nat-1" {
  network_id = yandex_vpc_network.network-1.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = "192.168.10.254"
  }
}


resource "yandex_vpc_subnet" "subnet-1" {
  name           = "public"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
  route_table_id =yandex_vpc_route_table.nat-1.id
}





