component extends="oauth2" accessors="true" {
  property name="client_id" type="string";
  property name="client_secret" type="string";
  property name="authEndpoint" type="string";
  property name="accessTokenEndpoint" type="string";
  property name="redirect_uri" type="string";
  
  // CRYPTR attributes
  property name="cryptr_base_url" type="string";
  property name="nonce" type="string";
  property name="accessToken" type="string";
  property name="idToken" type="string";
  property name="refreshToken" type="string";

  /**
  * I return an initialized cryptr object instance
  * @client_id The client ID for your applciation
  * @client_secret The client secret for your applciation
  * @authEndpoint The endpoint that handles authorization
  * @accessTokenEndpoint The endpoint that token generation
  * @redirect_uri The URL to redirect after the authentication
  **/
  public cryptr function init(
    required string cryptr_base_url,
    required string client_id,
    required string redirect_uri
  ) {
    setCryptr_base_url(arguments.cryptr_base_url);
    super.init(
      client_id           = arguments.client_id,
      client_secret       = createUUID(),
      authEndpoint        = arguments.cryptr_base_url,
      accessTokenEndpoint = "#arguments.cryptr_base_url#/org/:org_domain/oauth2/token",
      redirect_uri        = arguments.redirect_uri
    );

    return this;
  }

  /**
  * I return the string URL to use for user authentication
  *
  **/
  public string function buildRedirectToAuthURL(
    required string state = createUUID(),
    string email,
    string organization,
    array scope = ['openid', 'email', 'profile'],
    boolean usePKCE = true
  ) {
    nonce = createUUID();
    setNonce(nonce);
    var sParams = {
      'state' = arguments.state,
      'client_state' = arguments.state,
      'grant_type' = 'authorization_code',
      'nonce' = 'nonce'
    };

    if( len( arguments.email )) {
      structInsert( sParams, 'email', arguments.email )
    }
    
    if( len( arguments.organization )) {
      structInsert( sParams, 'organization', arguments.organization )
    }

    if( arrayLen(arguments.scope) ) {
      structInsert(sParams, 'scope', arrayToList(arguments.scope, ' '));
    }
    if( arguments.usePKCE ) {
      var stuPKCE = super.generatePKCE();
      setPKCE(stuPKCE);
      // Dump(stuPKCE);
      structAppend(sParams, stuPKCE);
    }

    return super.buildRedirectToAuthURL( sParams );
  }

  /**
  * I make the HTTP request to obtain tokens
  * @code The code returned from the authnetication request
  * @usePKCE Boolean value. Default true, if true the PKCE extension is triggered and will use the stored PKCE code_verifier
  **/
  public struct function makeAccessTokenRequest(
    required string code,
    required struct url,
    boolean usePKCE = true
  ){
    var aFormFields = [
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
      'name' = 'nonce',
      'value' = getNonce()
      },
    ];
    if( arguments.usePKCE ) {
      arrayAppend(aFormFields, {
        'name': 'code_verifier',
        'value': getPKCE()[ 'code_verifier' ]
      });
    }
    if (isDefined("url.organization_domain")) {
      setAccessTokenEndpoint("#getCryptr_base_url()#/org/#url.organization_domain#/oauth2/token")
    }
    res = super.makeAccessTokenRequest(code = arguments.code, formFields = aFormFields)
    if( res.success && isDefined("res.content")) {
      tokenResp = deserializeJSON(res.content);
      if( isDefined("tokenResp.access_token") ){
        setAccessToken(tokenResp.access_token)
      }
      if( isDefined("tokenResp.id_token") ){
        setIdToken(tokenResp.id_token)
      }
      if( isDefined("tokenResp.refresh_token") ){
        setRefreshToken(tokenResp.refresh_token)
      }
    }
    return res;
  }

  public function logOut() {
    if( isDefined("refreshToken")) {
      refresh_token = getRefreshToken();
      parts = refresh_token.listToArray(".")
      if (len(parts) > 1) {
        organization = parts.first();
        revokeTokenUrl = "#getCryptr_base_url()#/api/v1/tenants/#organization#/#getClient_id()#/oauth/token/revoke"
        Dump(revokeTokenUrl);
        var httpService = new http();
        httpService.setMethod("post");
        httpService.setCharset("utf-8");
        httpService.setUrl( revokeTokenUrl );
        httpService.addParam( type="formfield", name="token", value=refresh_token );
        httpService.addParam( type="formfield", name="token_type_hint", value="refresh_token" );
        result = httpService.send().getPrefix();
        Dump(result);
      }

    }
  }

  public struct function getUser(){
    if( isDefined("idToken") ){
      jwt = new jwt();
      return jwt.decode(token = getIdToken(), verify= false);
    } else {
      return {};
    }
  }
}