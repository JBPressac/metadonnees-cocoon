xquery version "3.0";

(:~ 
 : Defines all the RestXQ endpoints used by the XForms.
 :)

module namespace cocoon-form="http://localhost:8080/apps/restxq/cocoon-form";

import module namespace config="http://localhost:8080/apps/metadonnees-cocoon-app/config" at "../modules/config.xqm";

declare namespace rest="http://exquery.org/ns/restxq";
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";

declare variable $cocoon-form:data := $config:app-root || "/data/recordings";

(:~
 : List all recordings and return them as XML.
 :)
declare
    %rest:GET
    %rest:path("/recordings")
    %rest:produces("application/xml", "text/xml")
function cocoon-form:recordings() {
    <recordings>
    {
        for $recording in collection($config:app-root || "/data")/recording
        return
            $recording
    }
    </recordings>
};

(:~
 : Retrieve an recording identified by uuid.
 :)
declare 
    %rest:GET
    %rest:path("/recording/{$id}")
function cocoon-form:get-recording($id as xs:string*) {
    collection($cocoon-form:data)/recording[@id = $id]
};

(:~
 : Search recordings using a given field and a (lucene) query string.
 :)
declare 
    %rest:GET
    %rest:path("/search")
    %rest:form-param("query", "{$query}", "")
    %rest:form-param("field", "{$field}", "name")
function cocoon-form:search-recordings($query as xs:string*, $field as xs:string*) {
    <recordings>
    {
        if ($query != "") then
            switch ($field)
                case "title" return
                    collection($cocoon-form:data)/recording[ngram:contains(title, $query)]
                default return
                    collection($cocoon-form:data)/recording[ngram:contains(., $query)]
        else
            collection($cocoon-form:data)/recording
    }
    </recordings>
};

(:~
 : Update an existing recordings or store a new one. The recording XML is read
 : from the request body.
 :)
declare
    %rest:PUT("{$content}")
    %rest:path("/recording")
function cocoon-form:create-or-edit-recording($content as node()*) {
    let $id := ($content/recording/@id, util:uuid())[1]
    let $data :=
        <recording id="{$id}">
        { $content/recording/* }
        </recording>
    let $log := util:log("DEBUG", "Storing data into " || $cocoon-form:data)
    let $stored := xmldb:store($cocoon-form:data, $id || ".xml", $data)
    return
        cocoon-form:recordings()
};

(:~
 : Delete an recording identified by its uuid.
 :)
declare
    %rest:DELETE
    %rest:path("/recording/{$id}")
function cocoon-form:delete-recording($id as xs:string*) {
    xmldb:remove($cocoon-form:data, $id || ".xml"),
    cocoon-form:recordings()
};