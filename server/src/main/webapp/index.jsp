<html lang="en">

<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>

    <!--  BEGIN Browser History required section -->
    <link rel="stylesheet" type="text/css" href="history/history.css"/>
    <!--  END Browser History required section -->

    <title>Todo List</title>
    <script src="AC_OETags.js" language="javascript"></script>

    <!--  BEGIN Browser History required section -->
    <script src="history/history.js" language="javascript"></script>
    <!--  END Browser History required section -->

    <style>
        body {
            margin: 0px;
            overflow: hidden
        }
    </style>
    <script language="JavaScript" type="text/javascript">
        <!--
        // -----------------------------------------------------------------------------
        // Globals
        // Major version of Flash required
        var requiredMajorVersion = 9;
        // Minor version of Flash required
        var requiredMinorVersion = 0;
        // Minor version of Flash required
        var requiredRevision = 28;
        // -----------------------------------------------------------------------------
        // -->
    </script>
</head>

<body scroll="no">
<script language="JavaScript" type="text/javascript">
    <!--
    // Version check for the Flash Player that has the ability to start Player Product Install (6.0r65)
    var hasProductInstall = DetectFlashVer(6, 0, 65);

    // Version check based upon the values defined in globals
    var hasRequestedVersion = DetectFlashVer(requiredMajorVersion, requiredMinorVersion, requiredRevision);

    if (hasProductInstall && !hasRequestedVersion) {
        // DO NOT MODIFY THE FOLLOWING FOUR LINES
        // Location visited after installation is complete if installation is required
        var MMPlayerType = (isIE == true) ? "ActiveX" : "PlugIn";
        var MMredirectURL = window.location;
        document.title = document.title.slice(0, 47) + " - Flash Player Installation";
        var MMdoctitle = document.title;

        AC_FL_RunContent(
                "src", "playerProductInstall",
                "FlashVars", "MMredirectURL=" + MMredirectURL + '&MMplayerType=' + MMPlayerType + '&MMdoctitle=' + MMdoctitle + "",
                "width", "100%",
                "height", "100%",
                "align", "middle",
                "id", "findik-cafe-client-2.0-SNAPSHOT",
                "quality", "high",
                "bgcolor", "#869ca7",
                "name", "findik-cafe-client-2.0-SNAPSHOT",
                "allowScriptAccess", "sameDomain",
                "type", "application/x-shockwave-flash",
                "pluginspage", "/go/getflashplayer"
                );
    } else if (hasRequestedVersion) {
        // if we've detected an acceptable version
        // embed the Flash Content SWF when all tests are passed
        AC_FL_RunContent(
                "src", "findik-cafe-client-2.0-SNAPSHOT",
                "width", "100%",
                "height", "100%",
                "align", "middle",
                "id", "findik-cafe-client-2.0-SNAPSHOT",
                "quality", "high",
                "bgcolor", "#869ca7",
                "name", "findik-cafe-client-2.0-SNAPSHOT",
                "allowScriptAccess", "sameDomain",
                "type", "application/x-shockwave-flash",
                "pluginspage", "/go/getflashplayer"
                );
    } else {  // flash is too old or we can't detect the plugin
        var alternateContent = 'Alternate HTML content should be placed here. '
                + 'This content requires the Adobe Flash Player. '
                + '<a href=/go/getflash/>Get Flash</a>';
        document.write(alternateContent);  // insert non-flash content
    }
    // -->
</script>
<noscript>
    <object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"
            id="index" width="100%" height="100%"
            codebase="http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab">
        <param name="movie" value="findik-cafe-client-2.0-SNAPSHOT.swf"/>
        <param name="quality" value="high"/>
        <param name="bgcolor" value="#869ca7"/>
        <param name="allowScriptAccess" value="sameDomain"/>
        <embed src="findik-cafe-client-2.0-SNAPSHOT.swf" quality="high" bgcolor="#869ca7"
               width="100%" height="100%" name="findik-cafe-client-2.0-SNAPSHOT" align="middle"
               play="true"
               loop="false"
               quality="high"
               allowScriptAccess="sameDomain"
               type="application/x-shockwave-flash"
               pluginspage="/go/getflashplayer">
        </embed>
    </object>
</noscript>
</body>
</html>