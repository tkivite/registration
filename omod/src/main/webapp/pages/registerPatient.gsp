<%
    if (sessionContext.authenticated && !sessionContext.currentProvider) {
        throw new IllegalStateException("Logged-in user is not a Provider")
    }
   // ui.decorateWith("appui", "standardEmrPage")
    ui.includeJavascript("uicommons", "navigator/validators.js", Integer.MAX_VALUE - 19)
    ui.includeJavascript("uicommons", "navigator/navigator.js", Integer.MAX_VALUE - 20)
    ui.includeJavascript("uicommons", "navigator/navigatorHandlers.js", Integer.MAX_VALUE - 21)
    ui.includeJavascript("uicommons", "navigator/navigatorModels.js", Integer.MAX_VALUE - 21)
    ui.includeJavascript("uicommons", "navigator/exitHandlers.js", Integer.MAX_VALUE - 22);
    ui.includeJavascript("registration", "registerPatient.js");

    def genderOptions = [ [label: ui.message("emr.gender.M"), value: 'M'],
                          [label: ui.message("emr.gender.F"), value: 'F'] ]
%>
${ ui.includeFragment("uicommons", "validationMessages")}

<script type="text/javascript">
    jQuery(function() {
        KeyboardController();
    });
</script>

<script type="text/javascript">
    var breadcrumbs = [
        { icon: "icon-home", link: '/' + OPENMRS_CONTEXT_PATH + '/index.htm' },
        { label: "${ ui.message("registration.registration.label") }", link: "${ ui.pageLink("registration", "registerPatient") }" }
    ];

    var testFormStructure = "${formStructure}";
    
    var patientDashboardLink = '${ui.pageLink("coreapps", "clinicianfacing/patient")}';
    var getSimilarPatientsLink = '${ ui.actionLink("registration", "matchingPatients", "getSimilarPatients") }&appId=${appId}';
    
</script>

<div id="reviewSimilarPatients" class="dialog" style="display: none">
    <div class="dialog-header">
      <h3>${ ui.message("registration.reviewSimilarPatients")}</h3>
    </div>
    <div class="dialog-content">
        <p>
        	<em>${ ui.message("registration.selectSimilarPatient") }</em>
        </p>
        
        <ul id="similarPatientsSelect" class="select"></ul>
       
        <span class="button cancel"> ${ ui.message("registration.cancel") } </span>
    </div>
</div>

<div id="content" class="container">
    <h2>
        ${ ui.message("registration.registration.label") }
    </h2>

	<div id="similarPatients" class="highlighted" style="display: none;">
		   <div class="left" style="padding: 6px"><span id="similarPatientsCount"></span> ${ ui.message("registration.similarPatientsFound") }</div><button class="right" id="reviewSimilarPatientsButton">${ ui.message("registration.reviewSimilarPatients.button") }</button>
		   <div class="clear"></div>
	</div>
	

    <form class="simple-form-ui" id="registration" method="POST">
        <section id="demographics">
            <span class="title">${ui.message("registration.patient.demographics.label")}</span>

            <fieldset>
                <legend>${ui.message("registration.patient.name.label")}</legend>
			    
                <h3>${ui.message("registration.patient.name.question")}</h3>
                <% nameTemplate.lineByLineFormat.each { name ->
	                def initialNameFieldValue = ""
	                    if(patient.personName && patient.personName[name]){
	                        initialNameFieldValue = patient.personName[name]
	                    }
                %>
                    ${ ui.includeFragment("registration", "field/personName", [
                            label: ui.message(nameTemplate.nameMappings[name]),
                            size: nameTemplate.sizeMappings[name],
                            formFieldName: name,
                            dataItems: 4,
                            left: true,
                            initialValue: initialNameFieldValue,
                            classes: [(name == "givenName" || name == "familyName") ? "required" : ""]
                    ])}

                <% } %>
                <input type="hidden" name="preferred" value="true"/>
            </fieldset>

            <fieldset id="demographics-gender">
                <legend id="genderLabel">${ ui.message("emr.gender") }</legend>
                <h3>${ui.message("registration.patient.gender.question")}</h3>
                ${ ui.includeFragment("uicommons", "field/radioButtons", [
                        label: "",
                        formFieldName: "gender",
                        maximumSize: 3,
                        options: genderOptions,
                        classes: ["required"],
                        initialValue: patient.gender
                ])}
            </fieldset>

            <fieldset class="multiple-input-date no-future-date date-required">
                <legend id="birthdateLabel">${ui.message("registration.patient.birthdate.label")}</legend>
                <h3>${ui.message("registration.patient.birthdate.question")}</h3>
                ${ ui.includeFragment("uicommons", "field/multipleInputDate", [
                        label: "",
                        formFieldName: "birthdate",
                        left: true,
                        showEstimated: true,
                        estimated: patient.birthdateEstimated,
                        initialValue: patient.birthdate
                  ])}
            </fieldset>

        </section>
        <!-- read configurable sections from the json config file-->
        <% formStructure.sections.each { structure ->
            def section = structure.value
            def questions=section.questions
        %>
            <section id="${section.id}">
                <span id="${section.id}_label" class="title">${ui.message(section.label)}</span>
                    <% questions.each { question ->
                        def fields=question.fields
                    %>
                        <fieldset<% if(question.legend == "Person.address"){ %> class="requireOne"<% } %>>
                            <legend id="${question.id}">${ ui.message(question.legend)}</legend>
                            <% if(question.legend == "Person.address"){ %>
                                ${ui.includeFragment("uicommons", "fieldErrors", [fieldName: "personAddress"])}
                            <% } %>
                            <% fields.each { field ->
                                def configOptions = [
                                        label:ui.message(field.label),
                                        formFieldName: field.formFieldName,
                                        left: true,
                                        "classes": field.cssClasses
                                ]
                                if(field.type == 'personAddress'){
                                    configOptions.addressTemplate = addressTemplate
                                }
                            %>
                                ${ ui.includeFragment(field.fragmentRequest.providerName, field.fragmentRequest.fragmentId, configOptions)}
                            <% } %>
                        </fieldset>
                    <% } %>
            </section>
        <% } %>
        <div id="confirmation">
            <span id="confirmation_label" class="title">${ui.message("registration.patient.confirm.label")}</span>
            <div class="before-dataCanvas"></div>
            <div id="dataCanvas"></div>
            <div class="after-data-canvas"></div>
            <div id="confirmationQuestion">
                Confirm submission? <p style="display: inline"><input type="submit" class="submitButton confirm right" value="${ui.message("registration.patient.confirm.label")}" /></p><p style="display: inline"><input id="cancelSubmission" class="cancel" type="button" value="${ui.message("registration.cancel")}" /></p>
            </div>
        </div>
    </form>
</div>
