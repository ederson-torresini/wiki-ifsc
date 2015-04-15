<?php

$metadata['https://idpcafe.ifsc.edu.br/idp/shibboleth'] = array (
	'entityid' => 'https://idpcafe.ifsc.edu.br/idp/shibboleth',
	'description' =>
		array (
			'en' => 'IFSC - Instituto Federal de Santa Catarina',
		),
	'OrganizationName' =>
		array (
			'en' => 'IFSC - Instituto Federal de Santa Catarina',
		),
	'name' =>
		array (
			'en' => 'IFSC - Instituto Federal de Santa Catarina',
		),
	'OrganizationDisplayName' =>
		array (
			'en' => 'IFSC - Instituto Federal de Santa Catarina',
		),
  'url' => 
  array (
    'en' => 'http://www.ifsc.edu.br/',
  ),
  'OrganizationURL' => 
  array (
    'en' => 'http://www.ifsc.edu.br/',
  ),
  'contacts' => 
  array (
    0 => 
    array (
      'contactType' => 'technical',
      'surName' => 'Diretoria de TIC - IFSC',
      'emailAddress' => 
      array (
        0 => 'suporte.reitoria@ifsc.edu.br',
      ),
    ),
  ),
  'metadata-set' => 'saml20-idp-remote',
  'SingleSignOnService' => 
  array (
    0 => 
    array (
      'Binding' => 'urn:mace:shibboleth:1.0:profiles:AuthnRequest',
      'Location' => 'https://idpcafe.ifsc.edu.br/idp/profile/Shibboleth/SSO',
    ),
    1 => 
    array (
      'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST',
      'Location' => 'https://idpcafe.ifsc.edu.br/idp/profile/SAML2/POST/SSO',
    ),
    2 => 
    array (
      'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST-SimpleSign',
      'Location' => 'https://idpcafe.ifsc.edu.br/idp/profile/SAML2/POST-SimpleSign/SSO',
    ),
    3 => 
    array (
      'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect',
      'Location' => 'https://idpcafe.ifsc.edu.br/idp/profile/SAML2/Redirect/SSO',
    ),
  ),
  'SingleLogoutService' => 
  array (
  ),
  'ArtifactResolutionService' => 
  array (
    0 => 
    array (
      'Binding' => 'urn:oasis:names:tc:SAML:1.0:bindings:SOAP-binding',
      'Location' => 'https://idpcafe.ifsc.edu.br:8443/idp/profile/SAML1/SOAP/ArtifactResolution',
      'index' => 1,
    ),
    1 => 
    array (
      'Binding' => 'urn:oasis:names:tc:SAML:2.0:bindings:SOAP',
      'Location' => 'https://idpcafe.ifsc.edu.br:8443/idp/profile/SAML2/SOAP/ArtifactResolution',
      'index' => 2,
    ),
  ),
  'keys' => 
  array (
    0 => 
    array (
      'encryption' => true,
      'signing' => true,
      'type' => 'X509Certificate',
      'X509Certificate' => '
MIIDqDCCApACAQAwDQYJKoZIhvcNAQEFBQAwgZkxLDAqBgNVBAoTI0luc3RpdHV0 byBGZWRlcmFsIGRlIFNhbnRhIENhdGFyaW5hMQ0wCwYDVQQLEwREVElDMRYwFAYD VQQHEw1GbG9yaWFub3BvbGlzMRcwFQYDVQQIEw5TYW50YSBDYXRhcmluYTELMAkG A1UEBhMCQlIxHDAaBgNVBAMTE2lkcGNhZmUuaWZzYy5lZHUuYnIwHhcNMTQwNDEx MTg1ODA4WhcNMTcwNDEwMTg1ODA4WjCBmTEsMCoGA1UEChMjSW5zdGl0dXRvIEZl ZGVyYWwgZGUgU2FudGEgQ2F0YXJpbmExDTALBgNVBAsTBERUSUMxFjAUBgNVBAcT DUZsb3JpYW5vcG9saXMxFzAVBgNVBAgTDlNhbnRhIENhdGFyaW5hMQswCQYDVQQG EwJCUjEcMBoGA1UEAxMTaWRwY2FmZS5pZnNjLmVkdS5icjCCASIwDQYJKoZIhvcN AQEBBQADggEPADCCAQoCggEBAN9zndckjBha7MXIXo7pc8deKLY8l4j2LLmbN/PE DDirotT2nuxdk0zGBKCpB3ZxHTN83MjBSGLQ205com7jbuFxzAgTFyB8GKJU3E4L 7htHjpbNhbI7j9VLjbHcEZJeilEj+jViGUjgH1G7QO1GIpIPEakOzSOMWfvsl54E VgjK0PEBB4CUqGKHl1Rxu8D9jKLzD3TiciAWqSdwRFpyhfed7xqj4AHA49Sljpbr TOttEQ7RxmNEXApvMzTTyVJSeBae9+jcNKypp7VTB5YZcI4YI9HkE599xiNjK19q XrHrTu9RAg/21yTrmGOJRPdJtjRbc6skG1+cDMhbSezCInkCAwEAATANBgkqhkiG 9w0BAQUFAAOCAQEAc/Sgpg8yWTUBY45Yp1Rs4yY3r3kLlK771TdEIVK6uQbLIwzo /cidWUp9F7HoJSlT478Z1kpGVDw/nqX9HVKXVcwaGdpae2zq6SBVSmGuwx6WkI0+ fHw5DsGkY5CuMXIDRGW3G8uhO2dVIqSUaju1W8UCCrZbcWCWQJHPtDe7zGRgtuQV +uFs8FxtcQnLGOe0GmT48n9jW0ylQYrG5nbQ7jd0XQSGFMvuWj0tvM+i4q4XefHW iqG4LoRUqbCxPpagxpe/lKP1z8DQo0sWH/nfCuDYrSIvMV2PdMwIJqFVahF/QH6w +PpKrPXPFokR6cpvUAZYVpFuacTUNza0Knpicg==
',
    ),
  ),
  'scope' => 
  array (
    0 => 'ifsc.edu.br',
  ),
);
