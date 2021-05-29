<script src="https://cdnjs.cloudflare.com/ajax/libs/d3/3.5.3/d3.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/topojson/1.6.9/topojson.min.js"></script>
<script src="scripts/datamaps.world.min.js"></script>
<div id="map" style="margin-left: 7%; position: relative; width: 1300px; height: 860px;"></div>
<script>
    var TheMap = new Datamap({
        element: document.getElementById("map"),
        scope: 'world',
		projection: 'mercator',
        geographyConfig: {
            borderColor: "#000000",
            popupTemplate: function(geography, data) {
                var c;
                if (data == null) {
                    c = 0;
                } else {
                    if (data.infections == null) c = 0;
                    else c = data.infections;
                }
                return '<div class="hoverinfo"><strong>' + geography.properties.name + '</strong><br/>Infections: ' + c + '</div>'
            }
        },

        fills: {
            defaultFill: "#393942",
            infectedFill: "#aaf444"
        },
        data: {
<?php
			include('location.php');
			$NewMap = CountThemAll();
			$ToEcho = "";
			foreach($NewMap as $Country => $InfCount){
				$ToEcho .= "\t\t\t'$Country': {\r\n";
				$ToEcho .= "\t\t\t\tfillKey: 'infectedFill',\r\n";
				$ToEcho .= "\t\t\t\tinfections: $InfCount\r\n";
				$ToEcho .= "\t\t\t},\r\n";
			}
			$ToEcho = substr($ToEcho, 0, -3); //Get rid of the last comma
			$ToEcho .= "\r\n";
			echo $ToEcho;
			?>
        }
    });
</script>