import 'dart:io';

bool validateAddress(String? address) {
  return address != null
      && address.isNotEmpty
      && null != InternetAddress.tryParse(address);
}

bool validatePort(String? port) {
  if(port == null || port.isEmpty) {
    return false;
  }

  final int? portNum = int.tryParse(port);

  if(portNum == null) {
    return false;
  }

  if(portNum < 1000 && portNum > 65535) {
    return false;
  }

  return true;
}