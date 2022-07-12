
// const String API_URL = "https://jaagran.in/api/";
// const String Server_URL = "https://jaagran.in/";

const String API_URL = "https://swasthyasethu.in/api/";
const String Server_URL = "https://swasthyasethu.in/";
String AGORA_APP_ID = "20e14d78399147afa94b6c16fbc62d96";
const String someThingWentWrong = 'Something went wrong please try again after some time!';
void printToConsole(String msg) {
  // int len = msg.length;
  // int cntLen = 0;
  // while (cntLen <= len) {
  //   print(msg.substring(cntLen, (cntLen + 1000) > len ? len : (cntLen + 1000)));
  //   cntLen += 1000;
  // }
  print(msg);
}

String getImageUrl(String path){
  return Server_URL + path;
}
// HashMap<String, String> getNonCaseSensitiveParams() {
//   try {
//     final Map<String, String> params =
//         Uri.parse(html.window.location.href).queryParameters;
//
//     HashMap<String, String> hashMap = HashMap();
//     if (params != null) {
//       params.forEach((key, value) {
//         hashMap[key.toLowerCase()] = value;
//       });
//     }
//     return hashMap;
//   } on Exception catch (e) {
//     return HashMap();
//   }
// }
//
