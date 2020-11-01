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
 * This class will be utilised by
 * all the JS Controller methods
 * to return it's instance back to
 * JavaScript.
 *
 * @author      Shruti
 * @since       14/06/2020
 * @revisions   N/A
 */
global class EAPI_ActionResponse {
    @AuraEnabled
    public Boolean status { get; set; }
    @AuraEnabled
    public String message { get; set; }
    @AuraEnabled
    public Object datum { get; set; }

    /**
     * List of Standard or Custom
     * Object Records.
     */
    @AuraEnabled
    public List<SObject> dataRecords { get; set; }

    /**
     * List of user-defined class
     * instances.
     */
    @AuraEnabled
    public List<Object> dataCustom { get; set; }

    public EAPI_ActionResponse(Boolean status, String message, Object datum) {
        this.status = status;
        this.message = message;
        this.datum = datum;
    }

    /**
     * Constructor utilised when an
     * error occurs.
     */
    public EAPI_ActionResponse(Boolean status, String message) {
        this.status = status;
        this.message = message;
    }

    /**
     * Constructor utilised when
     * a list of standard or custom
     * object records are returned.
     */
    public EAPI_ActionResponse(
        Boolean status,
        String message,
        List<SObject> dataRecords
    ) {
        this.status = status;
        this.message = message;
        this.dataRecords = dataRecords;
        this.dataCustom = null;
    }

    /**
     * Constructor utilised when
     * a list of instances of a
     * user-defined class is returned.
     */
    public EAPI_ActionResponse(
        Boolean status,
        String message,
        List<Object> dataCustom
    ) {
        this.status = status;
        this.message = message;
        this.dataRecords = null;
        this.dataCustom = dataCustom;
    }
}