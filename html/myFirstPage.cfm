<cfimport path="oauth2.cfc"/>
<cfscript>
  cryptr_base_url = "https://766b-91-229-136-66.ngrok.io";
  org_domain = "decathlon";
  cryptr = new cryptr(
    cryptr_base_url     = "https://766b-91-229-136-66.ngrok.io",
    client_id           = '0139d3b2-b6d2-4802-95c1-fc0e75a390d8',
    redirect_uri        = 'http://localhost:84/myFirstPage.cfm'
  );

  cryptrSessionUrl = cryptr.buildRedirectToAuthURL();
  if (isDefined("url.authorization_code") && isDefined("url.request_id")) {
    cryptr.makeAccessTokenRequest(code = url.authorization_code, url = url);
  }
  if (isDefined("url.cryptr_form") && url.cryptr_form == 'log out') {
    cryptr.logOut();
  }
</cfscript>
<html>
  <head>
    <title>Home</title>
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
        <a href="#cryptrSessionUrl#" class="inline-flex items-center rounded-md border border-transparent bg-teal-600 px-4 py-2 text-sm font-medium text-white shadow-sm hover:bg-teal-700 focus:outline-none focus:ring-2 focus:ring-teal-500 focus:ring-offset-2">
          Se connecter
        </a>
        <a href="#cryptr.buildRedirectToAuthURL(email = 'tibo@decathlon.co')#" class="inline-flex items-center rounded-md border border-transparent bg-teal-600 px-4 py-2 text-sm font-medium text-white shadow-sm hover:bg-teal-700 focus:outline-none focus:ring-2 focus:ring-teal-500 focus:ring-offset-2">
          Se connecter (email)
        </a>
        <a href="#cryptr.buildRedirectToAuthURL(organization = 'decathlon')#" class="inline-flex items-center rounded-md border border-transparent bg-teal-600 px-4 py-2 text-sm font-medium text-white shadow-sm hover:bg-teal-700 focus:outline-none focus:ring-2 focus:ring-teal-500 focus:ring-offset-2">
          Se connecter (domain)
        </a>
        <form>
          <input  type="submit" name="cryptr_form" value="log out" class="inline-flex items-center rounded-md border border-transparent bg-red-600 px-4 py-2 text-sm font-medium text-white shadow-sm hover:bg-red-700 focus:outline-none focus:ring-2 focus:ring-red-500 focus:ring-offset-2"/>
        </form>
      </cfoutput>
      <div>
        <pre>
          <code>
            <cfdump var="#cryptr.getRefreshToken()#" label="getRefreshToken"/>
            <cfdump var="#cryptr.getUser()#" label="currentUser"/>
          </code>
        </pre>
      </div>
    </div>
  </body>
  </html>
