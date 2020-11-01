/**
 * Copyright (c) 2020, Shruti Sridharan
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *  • Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 *
 *  • Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
 * DAMAGE.
 */

/**
 * This class is created to make
 * requests to Einstein NER API.
 *
 * @author      Shruti Sridharan
 * @since       14/06/2020
 * @revisions   N/A
 **/
public with sharing class EAPI_Core {
    public class EAPIException extends Exception {
    }

    ////////////////////////
    //Einstein API Config //
    ////////////////////////
    public static Einstein_API_Settings__c settings {
        get {
            return Einstein_API_Settings__c.getInstance(
                UserInfo.getOrganizationId()
            );
        }
    }

    public static String tokenEndpoint {
        get {
            return settings.Token_Endpoint__c;
        }
    }

    public static Decimal tokenExpirationSeconds {
        get {
            return settings.Token_Expiration_Seconds__c;
        }
    }

    public static String registeredEmail {
        get {
            return settings.Registered_Email__c;
        }
    }

    public static String nerEndpoint {
        get {
            return settings.Einstein_NER_Endpoint__c;
        }
    }

    /////////////////
    //Auth Methods //
    /////////////////
    /**
     * This method is created to make a call
     * to the Token Endpoint and get the token
     * which will help us to make request to
     * other Endpoints of Einstein Services.
     *
     * @return  String  Returns the access token of the Org
     */
    public static String getAccessToken() {
        if (tokenEndpoint == null)
            throw new EAPIException(
                'Missing Token Endpoint on Custom Settings - Einstein API Settings.'
            );

        if (tokenExpirationSeconds == null)
            throw new EAPIException(
                'Missing Token Exp. Seconds on Custom Settings - Einstein API Settings.'
            );

        if (registeredEmail == null)
            throw new EAPIException(
                'Missing Registered Email on Custom Settings - Einstein API Settings.'
            );

        List<Document> base64Content = new List<Document>();
        base64Content = [
            SELECT Body
            FROM Document
            WHERE DeveloperName = 'einstein_platform_pem'
        ];

        if (base64Content.isEmpty())
            throw new EAPIException(
                'Private Key is Missing. Please upload the same to Document before proceeding.'
            );

        String keyContents = base64Content.get(0).Body.tostring();
        keyContents = keyContents.replace(
            '-----BEGIN RSA PRIVATE KEY-----',
            ''
        );
        keyContents = keyContents.replace('-----END RSA PRIVATE KEY-----', '');
        keyContents = keyContents.replace('\n', '');

        EAPI_JWT jwt = new EAPI_JWT('RS256');

        jwt.pkcs8 = keyContents;
        jwt.iss = 'developer.force.com';
        jwt.sub = registeredEmail;
        jwt.aud = tokenEndpoint;
        jwt.exp = String.valueOf(tokenExpirationSeconds);

        String accessToken = EAPI_JWTBearerFlow.getAccessToken(
            tokenEndpoint,
            jwt
        );

        return accessToken;
    }

    ////////////////////////////////
    //  Einstein NER API Methods  //
    ////////////////////////////////
    /**
     * This method is created to build
     * Http Requests.
     *
     * @param   method          The method of the Http Call
     * @param   endpoint        The endpoint to which the Http Call has to be made
     *
     * @return  HttpRequest     Instance of the HttpRequest class
     **/
    private static HttpRequest buildRequest(String method, String endpoint) {
        HttpRequest httpReq = new HttpRequest();

        httpReq.setMethod(method);

        httpReq.setEndpoint(endpoint);

        httpReq.setHeader('Authorization', 'Bearer ' + getAccessToken());
        httpReq.setHeader('Cache-Control', 'no-cache');
        httpReq.setHeader(
            'Content-Type',
            EAPI_HttpFormBuilder.getContentType()
        );

        httpReq.setTimeout(120000);

        return httpReq;
    }

    /**
     * Invoke the Einstein NER API to
     * scan the text and detect named
     * entities such as Name, Location etc.
     *
     * @param   text            Text to classify
     *
     * @return  String          Scan Results
     **/
    public static String detectEntities(String text) {
        if (nerEndpoint == null)
            throw new EAPIException(
                'Missing NER Endpoint on Custom Settings - Einstein API Settings.'
            );

        HttpRequest httpReq = buildRequest('POST', nerEndpoint);

        String mutipartFormData = '';

        mutipartFormData += EAPI_HttpFormBuilder.writeBoundary();
        mutipartFormData += EAPI_HttpFormBuilder.writeBodyParameter(
            'document',
            text
        );
        mutipartFormData += EAPI_HttpFormBuilder.writeBoundary(null);

        Blob formBlob = EncodingUtil.base64Decode(mutipartFormData);

        httpReq.setBodyAsBlob(formBlob);

        HttpResponse httpRes = new Http().send(httpReq);

        String responseBody = httpRes.getBody();

        return responseBody;
    }
}