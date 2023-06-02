unique template features/pakiti/client/config_schema;


type pakiti_client_config = {
    "curl"     : string_trimmed = "curl"
    "encrypt"  ? string_trimmed
    "expect"   : string_trimmed = "200 OK"
    "rndsleep" : long(0..86400) = 7200
    "site"     : string_trimmed
    "url"      : string_trimmed
};
