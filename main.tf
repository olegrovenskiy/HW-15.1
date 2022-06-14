terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  token     = "AQAAAABapegEAATuwQiNejL4zEschjtrCjlWlqU"
  cloud_id  = "cloud-orovenskiy"
  folder_id = "b1giu86qs432cv8j7c9p"
  zone      = "ru-central1-a"
}

resource "yandex_compute_instance" "nat-instance" {
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
    subnet_id = yandex_vpc_subnet.subnet-0.id
    ip_address = "192.168.10.254"
    nat       = true
  }

  metadata = {
    user-data = "${file("meta.txt")}"
  }


}

resource "yandex_compute_instance" "vm-public" {
  name = "publicvm"


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
    subnet_id = yandex_vpc_subnet.subnet-0.id
    nat       = true

  }

  metadata = {
    user-data = "${file("meta.txt")}"
  }

}

resource "yandex_compute_instance" "private-vm" {
  name = "privatevm"


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

resource "yandex_vpc_subnet" "subnet-0" {
  name           = "public"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.10.0/24"]

}

resource "yandex_vpc_subnet" "subnet-1" {
  name           = "private"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network-1.id
  v4_cidr_blocks = ["192.168.20.0/24"]
  route_table_id =yandex_vpc_route_table.nat-1.id
}





