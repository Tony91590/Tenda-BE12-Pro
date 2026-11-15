<?php
session_start();  
$apiUrl = "https://tivimate.b4a.io/functions/checkAppInfo_v2";
$token = null; // Initialize $token to avoid undefined variable notice

$rawPostData = file_get_contents("php://input");
$data = json_decode($rawPostData, true);

if (isset($data['requestToken'])) {
    $token = $data['requestToken'];
}

$headers = [
    "x-parse-application-id: D9FkEvZLiVTXvYzQjAFpLqApaGwFne1ZRULTWlOr",
    "x-parse-app-build-version: 5103",
    "x-parse-app-display-version: 5.1.0",
    "x-parse-app-package-name: ar.tvplayer.tv",
    "x-parse-app-data: 17f27",
    "x-parse-os-version: 9",
    "user-agent: Parse Android SDK API Level 31",
    "x-parse-installation-id: b3a7cef7-eaad-43ac-677e-33370648a4a5",
    "x-parse-client-key: FWKnOMn5YsusvMoG21wC5FSJsNUaO96tqw8ys7Zp",
    "content-type: application/json",
    "accept-encoding: gzip"
];

$body = json_encode([
    "checkBeta" => false,
    "versionCode" => 5103,
    "deviceObjectId" => "",
    "requestToken" => $token
]);

$response = fk($apiUrl, $body, $headers);
$datas = json_decode($response, true);
$responseToken = $datas['result']['responseToken'] ?? 0; // Fallback to 0 if responseToken is not set

$jsonString = '{
    "result": {
        "newApkUrl": "",
        "newVersionName": "",
        "shouldUpdateGooglePlayVersion": false,
        "forceAutoUpdate": false,
        "stagedRolloutDays": 0,
        "isActivated": true,
        "deviceName": "TV",
        "account": "andy@hax.net",
        "responseToken": 464977
    }
}';

$dataArray = json_decode($jsonString, true);
$dataArray['result']['newApkUrl'] = '';
$dataArray['result']['account'] = 'rtx@12.cx';
$dataArray['result']['responseToken'] = $responseToken;
$newJsonString = json_encode($dataArray, JSON_PRETTY_PRINT);

header('Content-Type: application/json');
echo $newJsonString;
session_destroy();

function fk($apiUrl, $body, $headers) {
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $apiUrl); 
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true); 
    curl_setopt($ch, CURLOPT_HTTPHEADER, $headers); 
    curl_setopt($ch, CURLOPT_POST, true); 
    curl_setopt($ch, CURLOPT_POSTFIELDS, $body); 
    curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
    
    $result = curl_exec($ch);
    if (curl_errno($ch)) {
        echo 'Curl error: ' . curl_error($ch);
    }
    curl_close($ch); // Close curl in the function
    return $result;
}
?>
