xquery version "1.0";

(: 
 : Main controller.
 :)

(: supprimé puis rétabli https://github.com/eXist-db/demo-apps/blob/master/examples/xforms/controller.xql#L6 car n'est à priori pas utilisé :)
import module namespace cocoon-form="http://localhost:8080/apps/restxq/cocoon-form" at "restxq-cocoon.xql";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;

(:~
 : Redirect requests for / to edit.html.
 :)
if ($exist:path = "/") then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="edit.html?restxq={request:get-context-path()}/restxq/"/>
    </dispatch>

else if (ends-with($exist:resource, ".html")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <view>
            <forward url="../modules/view.xql"/>
        </view>
        <error-handler>
    		<forward url="error-page.html" method="get"/>
			<forward url="../modules/view.xql"/>
		</error-handler>
    </dispatch>

else if (contains($exist:path, "/$shared/")) then
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="/shared-resources/{substring-after($exist:path, '/$shared/')}">
            <set-header name="Cache-Control" value="max-age=3600, must-revalidate"/>
        </forward>
    </dispatch>

else if (starts-with($exist:path, "/resources")) then
    (: images, css are contained in the top /resources/ collection. :)
    (: Relative path requests from sub-collections are redirected there :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <forward url="{$exist:controller}/../../{$exist:path}"/>
    </dispatch>

else
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>
