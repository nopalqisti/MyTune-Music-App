class Config {

  static const String serverIp = "192.168.1.205"; // UPDATE IP

  static const String baseUrl = "http://$serverIp/mytune_server/";
  
  // URL endpoint khusus untuk script upload
  static const String uploadUrl = "${baseUrl}upload.php";
}