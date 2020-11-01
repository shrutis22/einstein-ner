import { LightningElement, track } from "lwc";

import detectEntities from "@salesforce/apex/EinsteinDetectEntitiesCtrl.detectEntities";

export default class EinsteinDetectEntities extends LightningElement {
    @track textToClassify =
        "Sean Connery, the Scottish-born actor who was the first to utter the famous movie line, “the name’s Bond, James Bond,” has died. He was 90. His death was confirmed by his family, the BBC reported. Though he made more than 60 films, winning an Academy Award for his supporting role as an incorruptible lawman on the trail of Al Capone in “The Untouchables” (1987), Connery was most closely affiliated with the debonair fictional British spy he portrayed seven times.";
    @track detectionResults = null;
    @track prettifiedRawResults = null;
    @track beautifiedResults = null;

    @track componentState = {
        isBusy: false,
        hasError: false,
        message: null
    };

    //GETTERS
    get isTextValid() {
        return this.textToClassify.trim() !== "";
    }

    get isDetected() {
        return this.detectionResults ? true : false;
    }

    //LIFECYCLE EVENTS
    renderedCallback() {
        this._printBeautifiedResults();

        this._increaseTextareaHeight();
    }

    //EVENT HANDLERS
    handleTextareaChange(event) {
        this.textToClassify = event.target.value;
    }

    handleDetectEntities() {
        this.detectionResults = null;
        this.prettifiedRawResults = null;

        this.componentState.isBusy = true;

        detectEntities({ textToClassify: this.textToClassify }).then(
            (result) => {
                if (result.status) {
                    this.detectionResults = result.datum;
                    this.prettifiedRawResults = JSON.stringify(
                        JSON.parse(result.datum),
                        null,
                        2
                    );
                    this._surroundDetectedTokens();

                    this.componentState = {
                        isBusy: false,
                        hasError: false,
                        message: null
                    };
                } else {
                    this.componentState = {
                        isBusy: false,
                        hasError: true,
                        message: result.message
                    };
                }
            }
        );
    }

    //PRIVATE HELPERS
    _surroundDetectedTokens() {
        let result = JSON.parse(this.detectionResults);

        this.beautifiedResults = this.textToClassify;

        let traversedLabels = new Set();

        result.probabilities.forEach((probability) => {
            if (!traversedLabels.has(probability.token)) {
                traversedLabels.add(probability.token);
                this.beautifiedResults = this.beautifiedResults.replace(
                    probability.token,
                    `<span title="${probability.label.toLowerCase()}" class="token ${probability.label.toLowerCase()}">${
                        probability.token
                    }</span>`
                );
            }
        });
    }

    _printBeautifiedResults() {
        let e = this.template.querySelector(".beautified");

        if (e && this.beautifiedResults) e.innerHTML = this.beautifiedResults;
    }

    _increaseTextareaHeight() {
        let style = document.createElement("style");
        style.innerText = `.slds-textarea {height: 140px;}`;

        this.template.querySelector("lightning-textarea").appendChild(style);
    }
}