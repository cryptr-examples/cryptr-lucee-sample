<cfimport path="oauth2.cfc"/>
<cfscript>
  function init(){
    // cryptr_base_url = "https://samly.howto:4443";
    // cryptr_base_url = "http://localhost:4000";
    cryptr_base_url = "https://766b-91-229-136-66.ngrok.io";
    org_domain = "decathlon";
    strState = createUUID();
    return new oauth2(
      client_id           = '0139d3b2-b6d2-4802-95c1-fc0e75a390d8',
      client_secret       = 'XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXX',
      authEndpoint        = '#cryptr_base_url#/',
      accessTokenEndpoint = '#cryptr_base_url#/org/#org_domain#/oauth2/token',
      redirect_uri        = 'http://localhost:84/myFirstPage.cfm'
    );
  }
  oauth2 = init();
  nonce = "7cb77446-0f25-41f1-af49-f76529ac5e36";
  sessionParams = [
    client_state = strState,
    state = strState,
    grant_type = 'authorization_code',
    nonce = nonce,
    code_challenge = "E9Melhoa2OwvFrEMTJguCHaoeK1t8URWbuGJSstw-cM"
  ]
  sessionUrl = oauth2.buildRedirectToAuthURL(sessionParams);
  tokenReq = {};
  if (isDefined("url.authorization_code") && isDefined("url.request_id")) {
    tokenReq = oauth2.makeAccessTokenRequest(code = url.authorization_code, formfields = [
      {
      'name' = 'request_id',
      'value' = url.request_id
      },
      {
      'name' = 'authorization_id',
      'value' = url.authorization_id
      },
      {
      'name' = 'code',
      'value' = url.authorization_code
      },
      {
      'name' = 'client_state',
      'value' = url.state
      },
      {
      'name' = 'code_verifier',
      'value' = 'dBjftJeZ4CVP-mB92K27uhbUJU1p1r_wW1gFWFOEjXk'
      },
      {
      'name' = 'nonce',
      'value' = nonce
      },
    ])
  }
</cfscript>
<html>
  <head>
    <title>My First page</title>
    <meta charset="UTF-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="assets/css/lib/tailwind.css"></script>
  </head>
  <body class="md:content-auto">
    <div class="prose">
      <h1 class="text-3xl font-bold underline text-clifford my-2">
        Cryptr Lucee implementation
      </h1>
      <a href="/myFirstPage.cfm" class="inline-flex items-center rounded-md border border-transparent bg-teal-600 px-4 py-2 text-sm font-medium text-white shadow-sm hover:bg-teal-700 focus:outline-none focus:ring-2 focus:ring-teal-500 focus:ring-offset-2">
        Accueil
      </a>
      <hr class="my-8"/>
      <cfoutput>
        <p>The time id #now()#</p>
        <a href="#sessionUrl#" class="inline-flex items-center rounded-md border border-transparent bg-indigo-600 px-4 py-2 text-sm font-medium text-white shadow-sm hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2">
          Se connecter
        </a>
      </cfoutput>
      <div id="session-manager">
        <em>Manage your Cryptr session here</em>
      </div>
      <div>
        <pre>
          <code>
            <cfif structKeyExists(tokenReq, 'content')>
              <cfdump var="#tokenReq#" label="token response"/>
            </cfif>
          </code>
        </pre>
      </div>
    </div>
  </body>
  </html>
