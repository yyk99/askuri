<?php
//
//
//

function a($link, $text)
{
  return "<A href=\"$link\">$text</A>";
}

function aa($link, $text, $attr)
{
  return "<A href=\"$link\" $attr>$text</A>";
}

$chain = array (
		"title.htm",
		"002.htm",
		"003.htm",
		"004.htm",
		"005.htm",
		"006.htm",
		"007.htm",
		"008.htm",
		"009.htm",
		"010.htm",
		"011.htm",
		"012.htm",
		"013.htm",
		"014.htm",
		"015.htm",
		"016.htm",
		"017.htm",
		"018.htm",
		"019.htm",
		"020.htm",
		"021.htm",
		"022.htm",
		"023.htm",
		"024.htm",
		"ackno.htm",
		);
function navigator_bar()
{
  global $DOCUMENT_NAME, $chain;

  $page = basename($DOCUMENT_NAME);
  $indx = array_search($page, $chain);

  echo "<P>\n";
  //echo "Page: $page<BR>\n";
  //echo "Index: $indx\n";
  if(is_integer($indx)){
    if($indx){
      $prev = a($chain[$indx - 1], "Prev page");
    }else{
      $prev = "&nbsp;";
    }
    if($indx + 1 < sizeof($chain)){
      $next = a($chain[$indx + 1], "Next page");
    }else{
      $next = "&nbsp;";
    }
    echo "<TABLE width=\"100%\" border=\"0\">\n";
    echo "<TR>\n";
    echo "<TD align=\"left\" width=\"30%\">" . $prev . "</TD><TD width=\"40%\" align=\"center\">" . a("002.htm", "Table of contents") . "</TD><TD width=\"30%\" align=\"right\">" . $next . "</TD>\n";
    echo "</TR>\n";
    echo "<TR>\n";
    echo "<TD colspan=\"3\" align=\"center\">" . aa("http://askuri.com/RC/", "Home", "target=\"_top\"") . "</TD>\n";
    echo "</TR>\n";
    echo "</TABLE>\n";
  }else{
    echo "<TABLE width=\"100%\" border=\"0\">\n";
    echo "<TR>\n";
    echo "<TD align=\"center\">" . aa("http://askuri.com/RC/", "Home", "target=\"_top\"") . "</TD>\n";
    echo "</TR>\n";
    echo "</TABLE>\n";
  }
}

?>
