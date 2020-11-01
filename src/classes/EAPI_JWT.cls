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

public class EAPI_JWT {
    public String alg { get; set; }
    public String iss { get; set; }
    public String sub { get; set; }
    public String aud { get; set; }
    public String exp { get; set; }
    public String iat { get; set; }
    public Map<String, String> claims { get; set; }
    public Integer validFor { get; set; }
    public String cert { get; set; }
    public String pkcs8 { get; set; }
    public String privateKey { get; set; }

    public static final String HS256 = 'HS256';
    public static final String RS256 = 'RS256';
    public static final String NONE = 'none';

    public EAPI_JWT(String alg) {
        this.alg = alg;
        this.validFor = 300;
    }

    public String issue() {
        String jwt = '';

        JSONGenerator header = JSON.createGenerator(false);
        header.writeStartObject();
        header.writeStringField('alg', this.alg);
        header.writeEndObject();
        String encodedHeader = base64URLencode(
            Blob.valueOf(header.getAsString())
        );

        JSONGenerator body = JSON.createGenerator(false);
        body.writeStartObject();
        body.writeStringField('iss', this.iss);
        body.writeStringField('sub', this.sub);
        body.writeStringField('aud', this.aud);
        Long rightNow = (dateTime.now().getTime() / 1000) + 1;
        body.writeNumberField('iat', rightNow);
        body.writeNumberField('exp', (rightNow + validFor));
        if (claims != null) {
            for (String claim : claims.keySet()) {
                body.writeStringField(claim, claims.get(claim));
            }
        }
        body.writeEndObject();

        jwt =
            encodedHeader +
            '.' +
            base64URLencode(Blob.valueOf(body.getAsString()));

        if (this.alg == HS256) {
            Blob key = EncodingUtil.base64Decode(privateKey);
            Blob signature = Crypto.generateMac(
                'hmacSHA256',
                Blob.valueof(jwt),
                key
            );
            jwt += '.' + base64URLencode(signature);
        } else if (this.alg == RS256) {
            Blob signature = null;

            if (cert != null) {
                signature = Crypto.signWithCertificate(
                    'rsa-sha256',
                    Blob.valueOf(jwt),
                    cert
                );
            } else {
                Blob privateKey = EncodingUtil.base64Decode(pkcs8);
                signature = Crypto.sign(
                    'rsa-sha256',
                    Blob.valueOf(jwt),
                    privateKey
                );
            }
            jwt += '.' + base64URLencode(signature);
        } else if (this.alg == NONE) {
            jwt += '.';
        }

        return jwt;
    }

    private String base64URLencode(Blob input) {
        String output = encodingUtil.base64Encode(input);
        output = output.replace('+', '-');
        output = output.replace('/', '_');
        while (output.endsWith('=')) {
            output = output.subString(0, output.length() - 1);
        }
        return output;
    }
}