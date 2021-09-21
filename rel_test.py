import json, requests
IP_ADDRESS = "http://94.130.67.118"
PORT = "1235"
text_doc = "Bush started war in Iraq, but not due to COVID. "
document = {
    "text": text_doc,
    "spans": [],  # in case of ED only, this can also be left out when using the API
}

print(requests.post("{}:{}".format(IP_ADDRESS, PORT), json=document).json())

