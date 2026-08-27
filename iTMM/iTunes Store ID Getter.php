# Copyright (c) 2000-2026 Anthony Banta - MIT License
#!/usr/bin/php
<?php

// Usage:
// ./itunes_storefront_ids_scraper.php > itunes_storefront_ids.pl

// Maybe we'll need to update those for future iTunes versions. With the user
// agent and store front HTTP headers, we trick the server into thinking that
// our requests come from iTunes.
const ITUNES_USER_AGENT =
  'iTunes/12.1 (Macintosh; OS X 10.10.2) AppleWebKit/0600.3.18';
const X_APPLE_STORE_FRONT = '143441-1,28 ab:FLA0';
const COUNTRY_SELECTOR_PAGE_URL =
  'https://itunes.apple.com/WebObjects/MZStore.woa/wa/countrySelectorPage';

// Locale is U.S. English in UTF-8.
ini_set('default_charset', 'UTF-8');
setlocale(LC_ALL, 'en_US.UTF-8');

// Fetch iTunes country selection page with cURL.
$curl = curl_init();
curl_setopt($curl, CURLOPT_USERAGENT, ITUNES_USER_AGENT);
curl_setopt($curl, CURLOPT_HTTPHEADER, array(
  'X-Apple-Store-Front: ' . X_APPLE_STORE_FRONT,
));
curl_setopt($curl, CURLOPT_URL, COUNTRY_SELECTOR_PAGE_URL);
curl_setopt($curl, CURLOPT_RETURNTRANSFER, TRUE);
# Enable all supported encoding types.
curl_setopt($curl, CURLOPT_ENCODING, '');
$html = curl_exec($curl);
curl_close($curl);

// Interesting JSON data is between "its.serverData=" and "</script>".
$json = substr(strstr($html, 'its.serverData='), 15);
$json = strstr($json, "</script>", TRUE);
$server_data = json_decode($json);

// Loop through all countries, and store them in an array.
$countries = array();
// E.g. Korea, Republic of â†’ Republic of Korea
function sort_name_to_name ($str) {
  if (strpos($str, ',') === FALSE) {
    return $str;
  }
  return implode(' ', array_reverse(explode(', ', $str, 2)));
}
foreach ($server_data->pageData->pageData->regions as $region) {
  foreach ($region->storefronts as $storefront) {
    // Storefront ID is the first 6 characters of 'storefront'.
    $storefront_id = substr($storefront->storefront, 0, 6);
    // 3-letter country code is the first 3 characters of 'storefront'.
    $country_code = substr($storefront->info, 0, 3);
    $country_name = $storefront->name;
    // Manual modifications for readability.
    if ($country_name == 'UAE') {
      $country_name = 'United Arab Emirates';
    }
    $country_name = sort_name_to_name($country_name);
    $country_name_html = str_replace('&amp;', '&', htmlentities($country_name));
    $countries[$storefront_id] = array(
      'id' => $storefront_id,
      'code' => $country_code,
      'name' => $country_name,
      'name_html' => $country_name_html,
    );
  }
}

// Sort by numerical country ID.
ksort($countries);

// Output all countries in your preferred format. Here as Perl source code for
// ExifTool. If country name has accented letters, remove accents and add
// original name as comment in HTML.
function perl_escape_string ($str) {
  if (FALSE === strpos($str, "'")) {
    # No single quote in input.
    return sprintf("'%s'", $str);
  }
  if (FALSE === strpos($str, '"')) {
    # No double quote in input.
    return sprintf('"%s"', $str);
  }
  return sprintf("'%s'",
    str_replace(array("\\", "'"), array("\\\\", "\\'"), $str));
}
foreach ($countries as $country) {
  if ($country['name_html'] == $country['name']) {
    $country['name_html'] = '';
  } else {
    $country['name'] = iconv('UTF-8', 'ASCII//TRANSLIT', $country['name']);
  }
  echo str_repeat(' ', 12) . sprintf("%d => %s, # %s%s\n",
    $country['id'],
    perl_escape_string($country['name']),
    $country['code'],
    empty($country['name_html']) ? '' : ' (' . $country['name_html'] . ')');
}

?>
