
<!-- rnb-text-begin -->

---
title: "Rafael Nadal Model - Model Fit"
output: html_notebook
---

En el presente documento analizaremos los partidos de Nadal en busca de patrones que nos permitan predecir el resultado de su proximo partido.

Arrancamos con un setup del environment.



<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuP25ldXJhbG5ldFxuXG5gYGAifQ== -->

```r
?neuralnet

```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiTm8gZG9jdW1lbnRhdGlvbiBmb3Ig4oCYbmV1cmFsbmV04oCZIGluIHNwZWNpZmllZCBwYWNrYWdlcyBhbmQgbGlicmFyaWVzOlxueW91IGNvdWxkIHRyeSDigJg/P25ldXJhbG5ldOKAmVxuIn0= -->

```
No documentation for ‘neuralnet’ in specified packages and libraries:
you could try ‘??neuralnet’
```



<!-- rnb-output-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->


Importamos la data previamente trabajada y seleccionamos las variables a utilizar.


<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuXG5tYXRjaGVzX25hZGFsX29rIDwtIGltcG9ydChcIk91dHB1dC9tYXRjaGVzX25hZGFsX29rLlJkYXRhXCIpICU+JSBcbiAgYXNfdGliYmxlKClcblxuZ2xpbXBzZShtYXRjaGVzX25hZGFsX29rKVxuYGBgIn0= -->

```r

matches_nadal_ok <- import("Output/matches_nadal_ok.Rdata") %>% 
  as_tibble()

glimpse(matches_nadal_ok)
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiUm93czogMSwxMjNcbkNvbHVtbnM6IDQ0XG4kIExvY2F0aW9uICAgICAgICAgICAgICAgPGZjdD4gRG9oYSwgRG9oYSwgRG9oYSwgQXVja2xhbmQsIE1lbGJvdXJuZSwgTWVsYm91cm5lLCBNZWxib3VybmUsIE1lbGJvdXJuZSwgQnVlbn5cbiQgVG91cm5hbWVudCAgICAgICAgICAgICA8Y2hyPiBcIlFhdGFyIEV4eG9uIE1vYmlsIE9wZW5cIiwgXCJRYXRhciBFeHhvbiBNb2JpbCBPcGVuXCIsIFwiUWF0YXIgRXh4b24gTW9iaWwgT3BlblwiflxuJCBEYXRlICAgICAgICAgICAgICAgICAgIDxkYXRlPiAyMDA1LTAxLTA0LCAyMDA1LTAxLTA1LCAyMDA1LTAxLTA2LCAyMDA1LTAxLTExLCAyMDA1LTAxLTE4LCAyMDA1LTAxLTIwLCAyMDB+XG4kIFNlcmllcyAgICAgICAgICAgICAgICAgPGZjdD4gSW50ZXJuYXRpb25hbCwgSW50ZXJuYXRpb25hbCwgSW50ZXJuYXRpb25hbCwgSW50ZXJuYXRpb25hbCwgR3JhbmQgU2xhbSwgR3Jhbn5cbiQgQ291cnQgICAgICAgICAgICAgICAgICA8ZmN0PiBPdXRkb29yLCBPdXRkb29yLCBPdXRkb29yLCBPdXRkb29yLCBPdXRkb29yLCBPdXRkb29yLCBPdXRkb29yLCBPdXRkb29yLCBPdXRkflxuJCBTdXJmYWNlICAgICAgICAgICAgICAgIDxmY3Q+IEhhcmQsIEhhcmQsIEhhcmQsIEhhcmQsIEhhcmQsIEhhcmQsIEhhcmQsIEhhcmQsIENsYXksIENsYXksIENsYXksIENsYXksIENsYXl+XG4kIFJvdW5kICAgICAgICAgICAgICAgICAgPGZjdD4gMXN0IFJvdW5kLCAybmQgUm91bmQsIFF1YXJ0ZXJmaW5hbHMsIDFzdCBSb3VuZCwgMXN0IFJvdW5kLCAybmQgUm91bmQsIDNyZCBSb35cbiQgQmVzdE9mICAgICAgICAgICAgICAgICA8ZmN0PiAzLCAzLCAzLCAzLCA1LCA1LCA1LCA1LCAzLCAzLCAzLCAzLCAzLCAzLCAzLCAzLCAzLCAzLCAzLCAzLCAzLCAzLCAzLCAzLCAzLCAzflxuJCBXMSAgICAgICAgICAgICAgICAgICAgIDxkYmw+IDYsIDYsIDYsIDYsIDYsIDYsIDYsIDcsIDcsIDYsIDAsIDcsIDYsIDYsIDIsIDYsIDYsIDcsIDcsIDYsIDYsIDYsIDYsIDYsIDYsIDZ+XG4kIEwxICAgICAgICAgICAgICAgICAgICAgPGRibD4gMywgMiwgMiwgMywgMCwgMSwgMSwgNSwgNiwgMSwgNiwgNiwgMywgMiwgNiwgMCwgNCwgNiwgNSwgNCwgMSwgNCwgMiwgNCwgMiwgNH5cbiQgVzIgICAgICAgICAgICAgICAgICAgICA8ZGJsPiA3LCA2LCA2LCBOQSwgNiwgNCwgNiwgMywgNiwgNiwgNiwgNiwgNiwgNiwgNiwgNiwgNiwgNiwgNiwgNiwgNiwgNywgNiwgNiwgNiwgflxuJCBMMiAgICAgICAgICAgICAgICAgICAgIDxkYmw+IDYsIDQsIDcsIE5BLCA0LCA2LCAxLCA2LCAzLCAzLCAwLCAzLCAzLCA3LCAyLCA3LCA0LCAyLCAzLCAxLCAwLCA2LCAyLCA3LCA0LCB+XG4kIFczICAgICAgICAgICAgICAgICAgICAgPGRibD4gTkEsIE5BLCA2LCBOQSwgNiwgNCwgNiwgMSwgTkEsIE5BLCA2LCBOQSwgTkEsIDYsIDYsIDYsIE5BLCBOQSwgTkEsIE5BLCBOQSwgTn5cbiQgTDMgICAgICAgICAgICAgICAgICAgICA8ZGJsPiBOQSwgTkEsIDMsIE5BLCAyLCA2LCAzLCA2LCBOQSwgTkEsIDEsIE5BLCBOQSwgNCwgNCwgMSwgTkEsIE5BLCBOQSwgTkEsIE5BLCBOflxuJCBXNCAgICAgICAgICAgICAgICAgICAgIDxkYmw+IE5BLCBOQSwgTkEsIE5BLCBOQSwgNywgTkEsIDcsIE5BLCBOQSwgTkEsIE5BLCBOQSwgTkEsIE5BLCBOQSwgTkEsIE5BLCBOQSwgTkF+XG4kIEw0ICAgICAgICAgICAgICAgICAgICAgPGRibD4gTkEsIE5BLCBOQSwgTkEsIE5BLCA1LCBOQSwgNiwgTkEsIE5BLCBOQSwgTkEsIE5BLCBOQSwgTkEsIE5BLCBOQSwgTkEsIE5BLCBOQX5cbiQgVzUgICAgICAgICAgICAgICAgICAgICA8ZGJsPiBOQSwgTkEsIE5BLCBOQSwgTkEsIDYsIE5BLCA2LCBOQSwgTkEsIE5BLCBOQSwgTkEsIE5BLCBOQSwgTkEsIE5BLCBOQSwgTkEsIE5BflxuJCBMNSAgICAgICAgICAgICAgICAgICAgIDxkYmw+IE5BLCBOQSwgTkEsIE5BLCBOQSwgMywgTkEsIDIsIE5BLCBOQSwgTkEsIE5BLCBOQSwgTkEsIE5BLCBOQSwgTkEsIE5BLCBOQSwgTkF+XG4kIENvbW1lbnQgICAgICAgICAgICAgICAgPGZjdD4gQ29tcGxldGVkLCBDb21wbGV0ZWQsIENvbXBsZXRlZCwgUmV0aXJlZCwgQ29tcGxldGVkLCBDb21wbGV0ZWQsIENvbXBsZXRlZCwgQ35cbiQgUmVzdWx0ICAgICAgICAgICAgICAgICA8ZmN0PiBXaW4sIFdpbiwgTG9zZSwgTG9zZSwgV2luLCBXaW4sIFdpbiwgTG9zZSwgV2luLCBXaW4sIExvc2UsIFdpbiwgV2luLCBXaW4sIFdpflxuJCBSYW5rTmFkYWwgICAgICAgICAgICAgIDxkYmw+IDUxLCA1MSwgNTEsIDUwLCA1NiwgNTYsIDU2LCA1NiwgNDgsIDQ4LCA0OCwgNDgsIDQ4LCA0OCwgNDgsIDQ4LCAzOSwgMzksIDM5LCB+XG4kIFJhbmtSaXZhbCAgICAgICAgICAgICAgPGRibD4gMTYsIDM2LCAyMiwgMjAsIDY1LCAxNSwgMjgzLCAzLCA2MSwgNjYsIDgsIDU1LCA4NiwgNjAsIDU2LCA2MSwgODEsIDc3LCAxMiwgN35cbiQgUml2YWxOYW1lICAgICAgICAgICAgICA8ZmN0PiBZb3V6aG55IE0uLCBWZXJkYXNjbyBGLiwgTGp1YmljaWMgSS4sIEhyYmF0eSBELiwgQmVubmV0ZWF1IEouLCBZb3V6aG55IE0uLCBSflxuJCBQYXJ0aWRvc1VsdDZNZXNlcyAgICAgIDxpbnQ+IDEsIDIsIDMsIDQsIDUsIDYsIDcsIDgsIDksIDEwLCAxMSwgMTIsIDE0LCAxNCwgMTUsIDE2LCAxNywgMTgsIDE5LCAyMCwgMjEsIDJ+XG4kIFBhcnRpZG9zVWx0M01lc2VzICAgICAgPGludD4gMSwgMiwgMywgNCwgNSwgNiwgNywgOCwgOSwgMTAsIDExLCAxMiwgMTQsIDE0LCAxNSwgMTYsIDE3LCAxOCwgMTksIDIwLCAyMSwgMn5cbiQgUGFydGlkb3NVbHRNZXMgICAgICAgICA8aW50PiAxLCAyLCAzLCA0LCA1LCA2LCA3LCA4LCA2LCA2LCA3LCA4LCA5LCA5LCA5LCAxMCwgMTAsIDEwLCAxMSwgMTIsIDEzLCA0LCA0LCAzflxuJCBXUlVsdDZNZXNlcyAgICAgICAgICAgIDxkYmw+IDEuMDAwMDAwMCwgMS4wMDAwMDAwLCAwLjY2NjY2NjcsIDAuNTAwMDAwMCwgMC42MDAwMDAwLCAwLjY2NjY2NjcsIDAuNzE0Mjg1Nyx+XG4kIFdSVWx0M01lc2VzICAgICAgICAgICAgPGRibD4gMS4wMDAwMDAwLCAxLjAwMDAwMDAsIDAuNjY2NjY2NywgMC41MDAwMDAwLCAwLjYwMDAwMDAsIDAuNjY2NjY2NywgMC43MTQyODU3LH5cbiQgV1JVbHRNZXMgICAgICAgICAgICAgICA8ZGJsPiAxLjAwMDAwMDAsIDEuMDAwMDAwMCwgMC42NjY2NjY3LCAwLjUwMDAwMDAsIDAuNjAwMDAwMCwgMC42NjY2NjY3LCAwLjcxNDI4NTcsflxuJCBQYXJ0aWRvc1JpdmFsVWx0Nk1lc2VzIDxpbnQ+IDEsIDIsIDMsIDEsIDQsIDMsIDMsIDEyLCA5LCA4LCAxMywgMTIsIDUsIDEyLCAxMCwgMTMsIDYsIDEyLCA5LCAxMiwgOSwgMTQsIDF+XG4kIFBhcnRpZG9zUml2YWxVbHQzTWVzZXMgPGludD4gMSwgMiwgMywgMSwgNCwgMywgMywgMTIsIDksIDgsIDEzLCAxMiwgNSwgMTIsIDEwLCAxMywgNiwgMTIsIDksIDEyLCA5LCAxNCwgMX5cbiQgUGFydGlkb3NSaXZhbFVsdE1lcyAgICA8aW50PiAxLCAyLCAzLCAxLCA0LCAzLCAzLCAxMiwgNywgNiwgMTIsIDksIDQsIDgsIDYsIDksIDUsIDgsIDUsIDEyLCA4LCA1LCA1LCA2LCA1flxuJCBXUlJpdmFsVWx0Nk1lc2VzICAgICAgIDxkYmw+IDAuMDAwMDAwMCwgMC41MDAwMDAwLCAxLjAwMDAwMDAsIDEuMDAwMDAwMCwgMC4yNTAwMDAwLCAwLjMzMzMzMzMsIDAuNjY2NjY2Nyx+XG4kIFdSUml2YWxVbHQzTWVzZXMgICAgICAgPGRibD4gMC4wMDAwMDAwLCAwLjUwMDAwMDAsIDEuMDAwMDAwMCwgMS4wMDAwMDAwLCAwLjI1MDAwMDAsIDAuMzMzMzMzMywgMC42NjY2NjY3LH5cbiQgV1JSaXZhbFVsdE1lcyAgICAgICAgICA8ZGJsPiAwLjAwMDAwMDAsIDAuNTAwMDAwMCwgMS4wMDAwMDAwLCAxLjAwMDAwMDAsIDAuMjUwMDAwMCwgMC4zMzMzMzMzLCAwLjY2NjY2NjcsflxuJCBTZXRzTmFkYWwgICAgICAgICAgICAgIDxkYmw+IDIsIDIsIDEsIDAsIDMsIDMsIDMsIDIsIDIsIDIsIDEsIDIsIDIsIDIsIDIsIDIsIDIsIDIsIDIsIDIsIDIsIDIsIDIsIDIsIDIsIDJ+XG4kIFNldHNSaXZhbCAgICAgICAgICAgICAgPGRibD4gMCwgMCwgMiwgMSwgMCwgMiwgMCwgMywgMCwgMCwgMiwgMCwgMCwgMSwgMSwgMSwgMCwgMCwgMCwgMCwgMCwgMCwgMCwgMSwgMCwgMH5cbiQgU2V0c0dhbmFkb3NVbHRQYXJ0aWRvICA8ZGJsPiAwLCAyLCAyLCAxLCAwLCAzLCAzLCAzLCAyLCAyLCAyLCAxLCAyLCAyLCAyLCAyLCAyLCAyLCAyLCAyLCAyLCAyLCAyLCAyLCAyLCAyflxuJCBTZXRzUGVyZGlkb3NVbHRQYXJ0aWRvIDxkYmw+IDAsIDAsIDAsIDIsIDEsIDAsIDIsIDAsIDMsIDAsIDAsIDIsIDAsIDAsIDEsIDEsIDEsIDAsIDAsIDAsIDAsIDAsIDAsIDAsIDEsIDB+XG4kIFJlc3VsdFVsdFBhcnRpZG8gICAgICAgPGNocj4gTkEsIFwiV2luXCIsIFwiV2luXCIsIFwiTG9zZVwiLCBcIkxvc2VcIiwgXCJXaW5cIiwgXCJXaW5cIiwgXCJXaW5cIiwgXCJMb3NlXCIsIFwiV2luXCIsIFwiV2luXCIsflxuJCBSb3VuZFVsdFBhcnRpZG8gICAgICAgIDxjaHI+IE5BLCBcIjFzdCBSb3VuZFwiLCBcIjJuZCBSb3VuZFwiLCBcIlF1YXJ0ZXJmaW5hbHNcIiwgXCIxc3QgUm91bmRcIiwgXCIxc3QgUm91bmRcIiwgXCIybn5cbiQgSDJIUGFydGlkb3MgICAgICAgICAgICA8aW50PiAwLCAwLCAwLCAwLCAwLCAxLCAwLCAwLCAwLCAwLCAwLCAwLCAwLCAxLCAwLCAwLCAxLCAwLCAwLCAwLCAwLCAwLCAxLCAxLCAwLCAwflxuJCBIMkhHYW5hZG9zICAgICAgICAgICAgIDxpbnQ+IDAsIDAsIDAsIDAsIDAsIDEsIDAsIDAsIDAsIDAsIDAsIDAsIDAsIDEsIDAsIDAsIDEsIDAsIDAsIDAsIDAsIDAsIDEsIDAsIDAsIDB+XG4kIEgySFdSICAgICAgICAgICAgICAgICAgPGRibD4gTmFOLCBOYU4sIE5hTiwgTmFOLCBOYU4sIDEsIE5hTiwgTmFOLCBOYU4sIE5hTiwgTmFOLCBOYU4sIE5hTiwgMSwgTmFOLCBOYU4sIH5cbiJ9 -->

```
Rows: 1,123
Columns: 44
$ Location               <fct> Doha, Doha, Doha, Auckland, Melbourne, Melbourne, Melbourne, Melbourne, Buen~
$ Tournament             <chr> "Qatar Exxon Mobil Open", "Qatar Exxon Mobil Open", "Qatar Exxon Mobil Open"~
$ Date                   <date> 2005-01-04, 2005-01-05, 2005-01-06, 2005-01-11, 2005-01-18, 2005-01-20, 200~
$ Series                 <fct> International, International, International, International, Grand Slam, Gran~
$ Court                  <fct> Outdoor, Outdoor, Outdoor, Outdoor, Outdoor, Outdoor, Outdoor, Outdoor, Outd~
$ Surface                <fct> Hard, Hard, Hard, Hard, Hard, Hard, Hard, Hard, Clay, Clay, Clay, Clay, Clay~
$ Round                  <fct> 1st Round, 2nd Round, Quarterfinals, 1st Round, 1st Round, 2nd Round, 3rd Ro~
$ BestOf                 <fct> 3, 3, 3, 3, 5, 5, 5, 5, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3~
$ W1                     <dbl> 6, 6, 6, 6, 6, 6, 6, 7, 7, 6, 0, 7, 6, 6, 2, 6, 6, 7, 7, 6, 6, 6, 6, 6, 6, 6~
$ L1                     <dbl> 3, 2, 2, 3, 0, 1, 1, 5, 6, 1, 6, 6, 3, 2, 6, 0, 4, 6, 5, 4, 1, 4, 2, 4, 2, 4~
$ W2                     <dbl> 7, 6, 6, NA, 6, 4, 6, 3, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7, 6, 6, 6, ~
$ L2                     <dbl> 6, 4, 7, NA, 4, 6, 1, 6, 3, 3, 0, 3, 3, 7, 2, 7, 4, 2, 3, 1, 0, 6, 2, 7, 4, ~
$ W3                     <dbl> NA, NA, 6, NA, 6, 4, 6, 1, NA, NA, 6, NA, NA, 6, 6, 6, NA, NA, NA, NA, NA, N~
$ L3                     <dbl> NA, NA, 3, NA, 2, 6, 3, 6, NA, NA, 1, NA, NA, 4, 4, 1, NA, NA, NA, NA, NA, N~
$ W4                     <dbl> NA, NA, NA, NA, NA, 7, NA, 7, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA~
$ L4                     <dbl> NA, NA, NA, NA, NA, 5, NA, 6, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA~
$ W5                     <dbl> NA, NA, NA, NA, NA, 6, NA, 6, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA~
$ L5                     <dbl> NA, NA, NA, NA, NA, 3, NA, 2, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA~
$ Comment                <fct> Completed, Completed, Completed, Retired, Completed, Completed, Completed, C~
$ Result                 <fct> Win, Win, Lose, Lose, Win, Win, Win, Lose, Win, Win, Lose, Win, Win, Win, Wi~
$ RankNadal              <dbl> 51, 51, 51, 50, 56, 56, 56, 56, 48, 48, 48, 48, 48, 48, 48, 48, 39, 39, 39, ~
$ RankRival              <dbl> 16, 36, 22, 20, 65, 15, 283, 3, 61, 66, 8, 55, 86, 60, 56, 61, 81, 77, 12, 7~
$ RivalName              <fct> Youzhny M., Verdasco F., Ljubicic I., Hrbaty D., Benneteau J., Youzhny M., R~
$ PartidosUlt6Meses      <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 14, 14, 15, 16, 17, 18, 19, 20, 21, 2~
$ PartidosUlt3Meses      <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 14, 14, 15, 16, 17, 18, 19, 20, 21, 2~
$ PartidosUltMes         <int> 1, 2, 3, 4, 5, 6, 7, 8, 6, 6, 7, 8, 9, 9, 9, 10, 10, 10, 11, 12, 13, 4, 4, 3~
$ WRUlt6Meses            <dbl> 1.0000000, 1.0000000, 0.6666667, 0.5000000, 0.6000000, 0.6666667, 0.7142857,~
$ WRUlt3Meses            <dbl> 1.0000000, 1.0000000, 0.6666667, 0.5000000, 0.6000000, 0.6666667, 0.7142857,~
$ WRUltMes               <dbl> 1.0000000, 1.0000000, 0.6666667, 0.5000000, 0.6000000, 0.6666667, 0.7142857,~
$ PartidosRivalUlt6Meses <int> 1, 2, 3, 1, 4, 3, 3, 12, 9, 8, 13, 12, 5, 12, 10, 13, 6, 12, 9, 12, 9, 14, 1~
$ PartidosRivalUlt3Meses <int> 1, 2, 3, 1, 4, 3, 3, 12, 9, 8, 13, 12, 5, 12, 10, 13, 6, 12, 9, 12, 9, 14, 1~
$ PartidosRivalUltMes    <int> 1, 2, 3, 1, 4, 3, 3, 12, 7, 6, 12, 9, 4, 8, 6, 9, 5, 8, 5, 12, 8, 5, 5, 6, 5~
$ WRRivalUlt6Meses       <dbl> 0.0000000, 0.5000000, 1.0000000, 1.0000000, 0.2500000, 0.3333333, 0.6666667,~
$ WRRivalUlt3Meses       <dbl> 0.0000000, 0.5000000, 1.0000000, 1.0000000, 0.2500000, 0.3333333, 0.6666667,~
$ WRRivalUltMes          <dbl> 0.0000000, 0.5000000, 1.0000000, 1.0000000, 0.2500000, 0.3333333, 0.6666667,~
$ SetsNadal              <dbl> 2, 2, 1, 0, 3, 3, 3, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2~
$ SetsRival              <dbl> 0, 0, 2, 1, 0, 2, 0, 3, 0, 0, 2, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0~
$ SetsGanadosUltPartido  <dbl> 0, 2, 2, 1, 0, 3, 3, 3, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2~
$ SetsPerdidosUltPartido <dbl> 0, 0, 0, 2, 1, 0, 2, 0, 3, 0, 0, 2, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0~
$ ResultUltPartido       <chr> NA, "Win", "Win", "Lose", "Lose", "Win", "Win", "Win", "Lose", "Win", "Win",~
$ RoundUltPartido        <chr> NA, "1st Round", "2nd Round", "Quarterfinals", "1st Round", "1st Round", "2n~
$ H2HPartidos            <int> 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0~
$ H2HGanados             <int> 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0~
$ H2HWR                  <dbl> NaN, NaN, NaN, NaN, NaN, 1, NaN, NaN, NaN, NaN, NaN, NaN, NaN, 1, NaN, NaN, ~
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuIyBTRVBBUk8gVkFSSUFCTEVTIEEgVVRJTElaQVJcblxudmFyaWFibGVzIDwtIGMoXCJMb2NhdGlvblwiLCBcIlNlcmllc1wiLCBcIkNvdXJ0XCIsIFwiU3VyZmFjZVwiLCBcIkRhdGVcIixcbiAgICAgICAgICAgICAgIFwiUm91bmRcIiwgXCJCZXN0T2ZcIiwgXCJSYW5rTmFkYWxcIiwgXCJSYW5rUml2YWxcIixcbiAgICAgICAgICAgICAgIFwiUGFydGlkb3NVbHQ2TWVzZXNcIiwgXCJQYXJ0aWRvc1VsdDNNZXNlc1wiLCBcIlBhcnRpZG9zVWx0TWVzXCIsXG4gICAgICAgICAgICAgICBcIldSVWx0Nk1lc2VzXCIsIFwiV1JVbHQzTWVzZXNcIiwgXCJXUlVsdE1lc1wiLFxuICAgICAgICAgICAgICAgXCJQYXJ0aWRvc1JpdmFsVWx0Nk1lc2VzXCIsIFwiUGFydGlkb3NSaXZhbFVsdDNNZXNlc1wiLFxuICAgICAgICAgICAgICAgXCJQYXJ0aWRvc1JpdmFsVWx0TWVzXCIsIFwiV1JSaXZhbFVsdDZNZXNlc1wiLCBcIldSUml2YWxVbHQzTWVzZXNcIixcbiAgICAgICAgICAgICAgIFwiV1JSaXZhbFVsdE1lc1wiLCBcIlNldHNHYW5hZG9zVWx0UGFydGlkb1wiLCBcIlNldHNQZXJkaWRvc1VsdFBhcnRpZG9cIixcbiAgICAgICAgICAgICAgIFwiUmVzdWx0VWx0UGFydGlkb1wiLCBcIlJvdW5kVWx0UGFydGlkb1wiLCBcIkgySFBhcnRpZG9zXCIsIFwiSDJIR2FuYWRvc1wiLFxuICAgICAgICAgICAgICAgXCJSZXN1bHRcIilcblxuZGZfbWF0Y2hlcyA8LSBtYXRjaGVzX25hZGFsX29rICU+JSBcbiAgc2VsZWN0KGFsbF9vZih2YXJpYWJsZXMpKVxuXG5nbGltcHNlKGRmX21hdGNoZXMpXG5gYGAifQ== -->

```r
# SEPARO VARIABLES A UTILIZAR

variables <- c("Location", "Series", "Court", "Surface", "Date",
               "Round", "BestOf", "RankNadal", "RankRival",
               "PartidosUlt6Meses", "PartidosUlt3Meses", "PartidosUltMes",
               "WRUlt6Meses", "WRUlt3Meses", "WRUltMes",
               "PartidosRivalUlt6Meses", "PartidosRivalUlt3Meses",
               "PartidosRivalUltMes", "WRRivalUlt6Meses", "WRRivalUlt3Meses",
               "WRRivalUltMes", "SetsGanadosUltPartido", "SetsPerdidosUltPartido",
               "ResultUltPartido", "RoundUltPartido", "H2HPartidos", "H2HGanados",
               "Result")

df_matches <- matches_nadal_ok %>% 
  select(all_of(variables))

glimpse(df_matches)
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiUm93czogMSwxMjNcbkNvbHVtbnM6IDI4XG4kIExvY2F0aW9uICAgICAgICAgICAgICAgPGZjdD4gRG9oYSwgRG9oYSwgRG9oYSwgQXVja2xhbmQsIE1lbGJvdXJuZSwgTWVsYm91cm5lLCBNZWxib3VybmUsIE1lbGJvdXJuZSwgQnVlbn5cbiQgU2VyaWVzICAgICAgICAgICAgICAgICA8ZmN0PiBJbnRlcm5hdGlvbmFsLCBJbnRlcm5hdGlvbmFsLCBJbnRlcm5hdGlvbmFsLCBJbnRlcm5hdGlvbmFsLCBHcmFuZCBTbGFtLCBHcmFuflxuJCBDb3VydCAgICAgICAgICAgICAgICAgIDxmY3Q+IE91dGRvb3IsIE91dGRvb3IsIE91dGRvb3IsIE91dGRvb3IsIE91dGRvb3IsIE91dGRvb3IsIE91dGRvb3IsIE91dGRvb3IsIE91dGR+XG4kIFN1cmZhY2UgICAgICAgICAgICAgICAgPGZjdD4gSGFyZCwgSGFyZCwgSGFyZCwgSGFyZCwgSGFyZCwgSGFyZCwgSGFyZCwgSGFyZCwgQ2xheSwgQ2xheSwgQ2xheSwgQ2xheSwgQ2xheX5cbiQgRGF0ZSAgICAgICAgICAgICAgICAgICA8ZGF0ZT4gMjAwNS0wMS0wNCwgMjAwNS0wMS0wNSwgMjAwNS0wMS0wNiwgMjAwNS0wMS0xMSwgMjAwNS0wMS0xOCwgMjAwNS0wMS0yMCwgMjAwflxuJCBSb3VuZCAgICAgICAgICAgICAgICAgIDxmY3Q+IDFzdCBSb3VuZCwgMm5kIFJvdW5kLCBRdWFydGVyZmluYWxzLCAxc3QgUm91bmQsIDFzdCBSb3VuZCwgMm5kIFJvdW5kLCAzcmQgUm9+XG4kIEJlc3RPZiAgICAgICAgICAgICAgICAgPGZjdD4gMywgMywgMywgMywgNSwgNSwgNSwgNSwgMywgMywgMywgMywgMywgMywgMywgMywgMywgMywgMywgMywgMywgMywgMywgMywgMywgM35cbiQgUmFua05hZGFsICAgICAgICAgICAgICA8ZGJsPiA1MSwgNTEsIDUxLCA1MCwgNTYsIDU2LCA1NiwgNTYsIDQ4LCA0OCwgNDgsIDQ4LCA0OCwgNDgsIDQ4LCA0OCwgMzksIDM5LCAzOSwgflxuJCBSYW5rUml2YWwgICAgICAgICAgICAgIDxkYmw+IDE2LCAzNiwgMjIsIDIwLCA2NSwgMTUsIDI4MywgMywgNjEsIDY2LCA4LCA1NSwgODYsIDYwLCA1NiwgNjEsIDgxLCA3NywgMTIsIDd+XG4kIFBhcnRpZG9zVWx0Nk1lc2VzICAgICAgPGludD4gMSwgMiwgMywgNCwgNSwgNiwgNywgOCwgOSwgMTAsIDExLCAxMiwgMTQsIDE0LCAxNSwgMTYsIDE3LCAxOCwgMTksIDIwLCAyMSwgMn5cbiQgUGFydGlkb3NVbHQzTWVzZXMgICAgICA8aW50PiAxLCAyLCAzLCA0LCA1LCA2LCA3LCA4LCA5LCAxMCwgMTEsIDEyLCAxNCwgMTQsIDE1LCAxNiwgMTcsIDE4LCAxOSwgMjAsIDIxLCAyflxuJCBQYXJ0aWRvc1VsdE1lcyAgICAgICAgIDxpbnQ+IDEsIDIsIDMsIDQsIDUsIDYsIDcsIDgsIDYsIDYsIDcsIDgsIDksIDksIDksIDEwLCAxMCwgMTAsIDExLCAxMiwgMTMsIDQsIDQsIDN+XG4kIFdSVWx0Nk1lc2VzICAgICAgICAgICAgPGRibD4gMS4wMDAwMDAwLCAxLjAwMDAwMDAsIDAuNjY2NjY2NywgMC41MDAwMDAwLCAwLjYwMDAwMDAsIDAuNjY2NjY2NywgMC43MTQyODU3LH5cbiQgV1JVbHQzTWVzZXMgICAgICAgICAgICA8ZGJsPiAxLjAwMDAwMDAsIDEuMDAwMDAwMCwgMC42NjY2NjY3LCAwLjUwMDAwMDAsIDAuNjAwMDAwMCwgMC42NjY2NjY3LCAwLjcxNDI4NTcsflxuJCBXUlVsdE1lcyAgICAgICAgICAgICAgIDxkYmw+IDEuMDAwMDAwMCwgMS4wMDAwMDAwLCAwLjY2NjY2NjcsIDAuNTAwMDAwMCwgMC42MDAwMDAwLCAwLjY2NjY2NjcsIDAuNzE0Mjg1Nyx+XG4kIFBhcnRpZG9zUml2YWxVbHQ2TWVzZXMgPGludD4gMSwgMiwgMywgMSwgNCwgMywgMywgMTIsIDksIDgsIDEzLCAxMiwgNSwgMTIsIDEwLCAxMywgNiwgMTIsIDksIDEyLCA5LCAxNCwgMX5cbiQgUGFydGlkb3NSaXZhbFVsdDNNZXNlcyA8aW50PiAxLCAyLCAzLCAxLCA0LCAzLCAzLCAxMiwgOSwgOCwgMTMsIDEyLCA1LCAxMiwgMTAsIDEzLCA2LCAxMiwgOSwgMTIsIDksIDE0LCAxflxuJCBQYXJ0aWRvc1JpdmFsVWx0TWVzICAgIDxpbnQ+IDEsIDIsIDMsIDEsIDQsIDMsIDMsIDEyLCA3LCA2LCAxMiwgOSwgNCwgOCwgNiwgOSwgNSwgOCwgNSwgMTIsIDgsIDUsIDUsIDYsIDV+XG4kIFdSUml2YWxVbHQ2TWVzZXMgICAgICAgPGRibD4gMC4wMDAwMDAwLCAwLjUwMDAwMDAsIDEuMDAwMDAwMCwgMS4wMDAwMDAwLCAwLjI1MDAwMDAsIDAuMzMzMzMzMywgMC42NjY2NjY3LH5cbiQgV1JSaXZhbFVsdDNNZXNlcyAgICAgICA8ZGJsPiAwLjAwMDAwMDAsIDAuNTAwMDAwMCwgMS4wMDAwMDAwLCAxLjAwMDAwMDAsIDAuMjUwMDAwMCwgMC4zMzMzMzMzLCAwLjY2NjY2NjcsflxuJCBXUlJpdmFsVWx0TWVzICAgICAgICAgIDxkYmw+IDAuMDAwMDAwMCwgMC41MDAwMDAwLCAxLjAwMDAwMDAsIDEuMDAwMDAwMCwgMC4yNTAwMDAwLCAwLjMzMzMzMzMsIDAuNjY2NjY2Nyx+XG4kIFNldHNHYW5hZG9zVWx0UGFydGlkbyAgPGRibD4gMCwgMiwgMiwgMSwgMCwgMywgMywgMywgMiwgMiwgMiwgMSwgMiwgMiwgMiwgMiwgMiwgMiwgMiwgMiwgMiwgMiwgMiwgMiwgMiwgMn5cbiQgU2V0c1BlcmRpZG9zVWx0UGFydGlkbyA8ZGJsPiAwLCAwLCAwLCAyLCAxLCAwLCAyLCAwLCAzLCAwLCAwLCAyLCAwLCAwLCAxLCAxLCAxLCAwLCAwLCAwLCAwLCAwLCAwLCAwLCAxLCAwflxuJCBSZXN1bHRVbHRQYXJ0aWRvICAgICAgIDxjaHI+IE5BLCBcIldpblwiLCBcIldpblwiLCBcIkxvc2VcIiwgXCJMb3NlXCIsIFwiV2luXCIsIFwiV2luXCIsIFwiV2luXCIsIFwiTG9zZVwiLCBcIldpblwiLCBcIldpblwiLH5cbiQgUm91bmRVbHRQYXJ0aWRvICAgICAgICA8Y2hyPiBOQSwgXCIxc3QgUm91bmRcIiwgXCIybmQgUm91bmRcIiwgXCJRdWFydGVyZmluYWxzXCIsIFwiMXN0IFJvdW5kXCIsIFwiMXN0IFJvdW5kXCIsIFwiMm5+XG4kIEgySFBhcnRpZG9zICAgICAgICAgICAgPGludD4gMCwgMCwgMCwgMCwgMCwgMSwgMCwgMCwgMCwgMCwgMCwgMCwgMCwgMSwgMCwgMCwgMSwgMCwgMCwgMCwgMCwgMCwgMSwgMSwgMCwgMH5cbiQgSDJIR2FuYWRvcyAgICAgICAgICAgICA8aW50PiAwLCAwLCAwLCAwLCAwLCAxLCAwLCAwLCAwLCAwLCAwLCAwLCAwLCAxLCAwLCAwLCAxLCAwLCAwLCAwLCAwLCAwLCAxLCAwLCAwLCAwflxuJCBSZXN1bHQgICAgICAgICAgICAgICAgIDxmY3Q+IFdpbiwgV2luLCBMb3NlLCBMb3NlLCBXaW4sIFdpbiwgV2luLCBMb3NlLCBXaW4sIFdpbiwgTG9zZSwgV2luLCBXaW4sIFdpbiwgV2l+XG4ifQ== -->

```
Rows: 1,123
Columns: 28
$ Location               <fct> Doha, Doha, Doha, Auckland, Melbourne, Melbourne, Melbourne, Melbourne, Buen~
$ Series                 <fct> International, International, International, International, Grand Slam, Gran~
$ Court                  <fct> Outdoor, Outdoor, Outdoor, Outdoor, Outdoor, Outdoor, Outdoor, Outdoor, Outd~
$ Surface                <fct> Hard, Hard, Hard, Hard, Hard, Hard, Hard, Hard, Clay, Clay, Clay, Clay, Clay~
$ Date                   <date> 2005-01-04, 2005-01-05, 2005-01-06, 2005-01-11, 2005-01-18, 2005-01-20, 200~
$ Round                  <fct> 1st Round, 2nd Round, Quarterfinals, 1st Round, 1st Round, 2nd Round, 3rd Ro~
$ BestOf                 <fct> 3, 3, 3, 3, 5, 5, 5, 5, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3~
$ RankNadal              <dbl> 51, 51, 51, 50, 56, 56, 56, 56, 48, 48, 48, 48, 48, 48, 48, 48, 39, 39, 39, ~
$ RankRival              <dbl> 16, 36, 22, 20, 65, 15, 283, 3, 61, 66, 8, 55, 86, 60, 56, 61, 81, 77, 12, 7~
$ PartidosUlt6Meses      <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 14, 14, 15, 16, 17, 18, 19, 20, 21, 2~
$ PartidosUlt3Meses      <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 14, 14, 15, 16, 17, 18, 19, 20, 21, 2~
$ PartidosUltMes         <int> 1, 2, 3, 4, 5, 6, 7, 8, 6, 6, 7, 8, 9, 9, 9, 10, 10, 10, 11, 12, 13, 4, 4, 3~
$ WRUlt6Meses            <dbl> 1.0000000, 1.0000000, 0.6666667, 0.5000000, 0.6000000, 0.6666667, 0.7142857,~
$ WRUlt3Meses            <dbl> 1.0000000, 1.0000000, 0.6666667, 0.5000000, 0.6000000, 0.6666667, 0.7142857,~
$ WRUltMes               <dbl> 1.0000000, 1.0000000, 0.6666667, 0.5000000, 0.6000000, 0.6666667, 0.7142857,~
$ PartidosRivalUlt6Meses <int> 1, 2, 3, 1, 4, 3, 3, 12, 9, 8, 13, 12, 5, 12, 10, 13, 6, 12, 9, 12, 9, 14, 1~
$ PartidosRivalUlt3Meses <int> 1, 2, 3, 1, 4, 3, 3, 12, 9, 8, 13, 12, 5, 12, 10, 13, 6, 12, 9, 12, 9, 14, 1~
$ PartidosRivalUltMes    <int> 1, 2, 3, 1, 4, 3, 3, 12, 7, 6, 12, 9, 4, 8, 6, 9, 5, 8, 5, 12, 8, 5, 5, 6, 5~
$ WRRivalUlt6Meses       <dbl> 0.0000000, 0.5000000, 1.0000000, 1.0000000, 0.2500000, 0.3333333, 0.6666667,~
$ WRRivalUlt3Meses       <dbl> 0.0000000, 0.5000000, 1.0000000, 1.0000000, 0.2500000, 0.3333333, 0.6666667,~
$ WRRivalUltMes          <dbl> 0.0000000, 0.5000000, 1.0000000, 1.0000000, 0.2500000, 0.3333333, 0.6666667,~
$ SetsGanadosUltPartido  <dbl> 0, 2, 2, 1, 0, 3, 3, 3, 2, 2, 2, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2~
$ SetsPerdidosUltPartido <dbl> 0, 0, 0, 2, 1, 0, 2, 0, 3, 0, 0, 2, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0~
$ ResultUltPartido       <chr> NA, "Win", "Win", "Lose", "Lose", "Win", "Win", "Win", "Lose", "Win", "Win",~
$ RoundUltPartido        <chr> NA, "1st Round", "2nd Round", "Quarterfinals", "1st Round", "1st Round", "2n~
$ H2HPartidos            <int> 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 1, 0, 0~
$ H2HGanados             <int> 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0~
$ Result                 <fct> Win, Win, Lose, Lose, Win, Win, Win, Lose, Win, Win, Lose, Win, Win, Win, Wi~
```



<!-- rnb-output-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->



Como proximo paso, eliminamos las primeras 50 observaciones ya que contienen campos con informacion incompleta (partidos jugados en ult. 6 meses, partidos ganados, etc.)



<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuXG4jRXN0YXMgbm8gbWUgc2lydmVuIHBvcnF1ZSBubyB0ZW5nbyByZWdpc3RybyBkZSBsb3MgcGFydGlkb3MgYW50ZXJpb3Jlc1xuXG5kZl9tYXRjaGVzICU+JVxuICBzZWxlY3QoTG9jYXRpb24sIFJhbmtOYWRhbCxcbiAgICAgICAgIFBhcnRpZG9zVWx0Nk1lc2VzLCBQYXJ0aWRvc1VsdDNNZXNlcywgUGFydGlkb3NVbHRNZXMpICU+JSBcbiBwcmludChuID0gNzApXG5gYGAifQ== -->

```r

#Estas no me sirven porque no tengo registro de los partidos anteriores

df_matches %>%
  select(Location, RankNadal,
         PartidosUlt6Meses, PartidosUlt3Meses, PartidosUltMes) %>% 
 print(n = 70)
```

<!-- rnb-source-end -->

<!-- rnb-frame-begin eyJtZXRhZGF0YSI6eyJjbGFzc2VzIjpbInRibF9kZiIsInRibCIsImRhdGEuZnJhbWUiXSwibnJvdyI6MTEyMywibmNvbCI6NSwic3VtbWFyeSI6eyJBIHRpYmJsZSI6WyIxLDEyMyB4IDUiXX19LCJyZGYiOiJINHNJQUFBQUFBQUFCdTFjVzNmVVJoSnVZSHlac1RGRElJRndIUUpaRnJLWWUwaXlaQU0yT1FGaXN3YUh5KzVMNkpscHhscHJKQitOQkF0UC9OeDkzQit3SjJ6TG8ycVZ5OVc2ak1kMk9Cbk8rU2gxcTlYZDlYVlZkV2tzNmNtOUY5ZHJMMnBDaUgyaXNrZi9QNllQeGZqODB0VnJONjhKVWRtclMzdEVSVlJqK1c5OS9wQSswRzMyN2RmNGp6NCtpVENwY1l2Z0VNSnhCbnNaZkdlQlFyaHRRWTNCWXdzZVp1Q2N4dVVFMHd4ZU12aWJCVWMxNWhIMk03ak80R3VDVXd6K3pPQzdIZURuRWNMbERMUVFqaExNTS9nMUFlYmhCY0VSQWlrMjI5MnRBandCVnhoYjRleExCc1BnOENXRFBCdWJKeHh5NCtmeGVzVENhNHduQ1lyWUlvY3lQRytGMTdJMldzWldLY2VVWnh3YmJUeGlMakYyd2w2NW1FTzVwRFpXaEJNYTI2aWR2V0RHd2V0eGtnSEhXMUY3NHpnYWxJK3R4a0JxV3pZT1kxUVJtZ3lBUzI3TVFma2Joczl5UEc3WC9rTHRNb3ZQb2h3VzRXNFlOcGpGM1NENUNzNVpPZ1JQQ2JpOHkyWVBPN251c0tiYy9sWTAvdGh5ckRJeHFHd3NBaXd4S09OWHcrWVQyd1NBY2pLRllOT1A2blNJd09ZRE5ydkowNDNUNVNVQmpnMWNqc0RaVDFrYm1XS1FaVE0yZThGY1VTN0w1UEJGL003R284MXZxUDUxaEN4Yno0c2gyNzJQNU1VUnVrK1UyU3VLMkFhTklaY3RQQTJpN3lCeGs4R0dHL2h4VjcxV2JpOVpXVGVwclovdlhicXZndER2S0svcDkxb3JTZjNrM1paY2k5eVdiOHB0NVVxbnJaSnk3VzVYQmIxWHZoK0VTYzNFWFMrVTdsdUppbTlVc0dhS29TdDFBOU5kMUZyVkZXMDRQU2U5enFxL21oU3JjekpvS2RmM29QM1luT3dwbVBPNExvUXl2VlE1LzNLOER2UThwOXhPSU0xRXgrZjhqcCtPT3hjNHZhYjBsQmtvYXEzSVFQVkMweUJxeTdXMFBEMFhLYy92TmU0NnVoRzBtWmNkMTVHQkExek15NTVzYW0xYVJ2bjVGZVYxMmhFdWVqSnQ3M2d0UjFlRWptbmd1MzdIekVvWGc3YmZoTjRPelB0YTM4WTl2N0VzSTJjTldrM2ZVMjRnM3pibWxEVExWcm5ucnhqTzdrWE5kTXg3VVU4ejJQYURWMUR6bzJheDZVZEJPdXlQdmRBUEhFUHpUOHBUcjZVcDZUa1kwc2Z1UzljMTE5MlgzV1lVd0FvY3VPODM1bGVjeHFMak5lYWQ4SzFwNVVlNmZ3OW0vOEJyTzlKclBGZXUyOXRZSjlkODF6RmtQOURqZXMwSVpqWDlVR3ZvZWFxSFJxeis3SVR2bXRHS3NaRHBueVBweXNaQzFGMkxBbWkwSUh1Tlo2b2pvZWZ4QmQ5cm0vbE1MY1NyN0hXVWE5YTVHbGZOUyswV3dPN0NXOU4rZkZHMkF3ZjRtRnlVUVZOckFteFZkVG1RcThvc1RGelJVMDVLV25WUnVSdlpYMVRkdFJXamQyVlJoZStBN1VWSGRwMjBvRTBOWnIzb2U2SFNrd3hjSDFldDZiazRLakN6MDFXQmttWmxGN1duKzI5TUtlcW1ocUpMbnBOTys1RjYwN2d2WHlzWWNES3UrSWNmZ0tkTzZQSmFHZ1FxajV5V0NSR1AvRERVanJraXU2WW1DaTR0UjI1bzVqLytkK1VFWmtVbWxxU3JnaTVvTXJha2ZheUhDbDJndDdha2g5VEJDaG4rVW1TWW5Ib2NLZVhwcFhPakpsejlPSEpDNkhmbWllTTMycXJ4VU1jQko0RGF5aE8vYXhibmlaNjZDdHBtNXBQTDJsUWYrajJGeXFFak8zQnhkVm42alNVWm1WWFFEWUsyNHpsbXhzc3QzV1d2TGQyMEMyM0htaHduTFN2djNZcGh1cnFzdWRPdUVNQUZZOHYrSzlPZkxxejV3UHJNY2pqYldGSjZ4dGdyYXV1MXZodWlMa08vdGJyaXU5MjBJZ3JEampUck43Nzh0dTBwY05teFgvelZ0NkRSeEM5K29NM0kwUFcwSzAzTWZhYlYwaUhOeElwblRoenZ3Qm1mT1o3VWZMc043UVBRNHJsMkJ3a1dXSHN1ZXl0YTJ6UTY3SC91ZUhHd3VMU3NlNGJaanY5VGRnTFZOS1dWS0dadjR5NDMxbkpsRHpZNXMvVzlraTBkMmZUUmJ6RmI4WS9YZHg2OEYvRy96VkwwNVVLT3ZMOUZPZisrbVB4QmxKTlhoeVQvVkZDZUtDa1BEeWduZDBpS2tSekprUnpKa1J6SmtmeFk1QS8vSGNrL2tyd2pMSEtVRDJiTG9uclhDOHFkeXN1SHRDNjdiYmNqT1pLL0IzbEhqT1JISlhkN3Z4cjBkNXMvdXF3UEtNdGV2OXYya2NqZGptc2orZnVTZDBTTzNLbDhzWjRqeS9hM1hYNWY5dmQwS3M5dHMvekNJaHREbGx2bEFlUlJpOXp0ZldFays3SnVrWERlWm0rRFNwczlGSlhEc3N0aC9WMXMyUEhISnNWdzVHN3ZSeCtydkNPS3laMmFqMWgvS0c3OUpiQTlvdi93M3o2TmlsaC9RVXlNYTB5SS9rdGg2My9oRi8ySEorT1hwMllTSEJEOXY5SWYxUGhFOUIrT2pLMzNVNDNQUlA4RmxOanJQdGM0SnZvdmpNWGVFajlVR2I5d2NscWpvWEZHSS9idXM2TC93R3Y4OEdmODErbnpvdjhnNGdXTml4cGZhZnhGNDVMR3JPZy9KSGRGNDZyR05kRi84TzZHeGszUmYrRXFmbmp2RzQxdnlURTh5UGd0S2Y4VnlSanhnMzd3NE9GdHBrL2M3dnRrYmdDWUkrVUpKT1hzRXdTb293L3A3aWEzTnhMZ2h4eHZKT2NwLzNEdEpRUTZQbjZRTTBzSHJPZVJST2JwUEFnUHdBVStMbXB6TjhWR202UGxXeUo5Q1JES1lFTmdmMkJIK1BoN3hPOVZ5eHd1SmZQN0tzRXBrVDY0RFBxZlJ2VWNUNFBhRDJkTDV4RXdqNFB3YXZObDdMOVFoOXQrUTlvQ241algyK2lZam9VZndzWDI5M2x5ZkFUSkxGOHM2cU40bmJJNEg5Ui84VVAxZWRmQzlVWFdGVDhrZjRvcEY3R2hvbmFIWDFUTTZ2Y3NNMDVSM1cxMmVMMWdPN0FoN1A5NWRnMXg5UUxCeFlJYzV0a1d0cXRHQ2I2TDhnWHhaeXUrbk5jR3gwbXVUMWlqc3dobDlzaWliUWZkYTRGSExpNW0yUlhrWUZXeE9RZUxYMmdvazRQWmNnZDRrWC9ZdVFPV1Z4TE1rakxzYTFSdmtOeDhhRnM2ajRzSkxxRGpzdnJnZHRBMnJ3OWJuN2lmWWVXMzF4aHVUcUkxNUhKMmJDODQvendzc3ZQS1kweDV1M0xPUEI2Z2pNOXovVjBrWmE0L25KdlM4MWxyYVZ0UDJ6Vm5jdmlBZGxuMmdjdkFOK1VjcjhWeFpzM3JnbzhSVUM1emp6SEYxRzNIZmNjVlVyYXRJNjBERlBVcDNNNldreFNOdmZoNEdQZHNaOFh1M0tmajQ2emNvb0htbkxYbStENGtTMWQ2bndMN0xzYXhaTzd3a1l1aklvMU54OFhtajJEUWUwYnV2cm9zdDJYMzN5TDNyRnliazVaampzUFBFT2o0QUZ6bWRKZ1I2UXVUTTR6TzB3a29EN1JjTDhBTG5Cc2tCbkVjTkFSdlUrZEltV3NIOXZxbFNGL0doenBzdXlDUEVkQ1hUVGxlY1ozTmZyamZoc3JhR3dCc1lhdTJTZTJNODNYTTM5a01uRUhnNnI0UTZSNUdRZldlUWNBK1NuMTJHUG16N2ZjbkdpTXhiUGZHTnYrZFRNREZuSzNFSUpDZ0R6NVhKemhvNmJmb21MVHVVQWwraSs2SnB5MW9KUDFpMEhzZyt0c3F6QVhtbURkUDd0dzBBYmRHWmRldHlEcmkvVzlZK1JpK1p3V0FYMlArUGtWOEhXUjB5ZElUbCtsTDlGbDJYcFM3T3JPZXc4ckx6b2pOOTF5UU8xVEU5dVVPTkEranNlVVVBenhQTHFhZlFCelZSYm9YYy94aERnK1NjMXp1bEtjUEJ0VGwyUXJ0czB5dUFXUEFPUm9EaXRxRHpVWUFKOGhhWmVXVkZRSnFOK0FUVThLZVYyQjlxUTYyWEpEcUFPdGdPdzg2NGR5YjQ1WHlqdWRXeE43eGZHMzdMNDU1aDhYbWVBK3hoK2FyZVg3SDFSV05FN0RlK0J5c1o5Nzl4Qmc2UCt6N3VZclliQnQwYnl3VC83alkwbUN1Z1JpQjUzb0FvWTdxNnFTK3lCNE1NWVBqQy9zU25OK3ArN2lpOStuY25IQ09pdjBlNWdoNkRlUCtsTm83eGlUVEgrVFFlSzQybThWdGFzazVYQThmWVpvV20vMkE4c0x4V09ZK25ZSzdyaXlIUmZqQjQwK0x6ZlBZazh5ajZGcHlPbVAreS9CQzIrVnhNRzFaWTg1dXMzakQ0Tm9kRU9sdkR4RG5nQy9zRjFESHpYV0MwWVBxVnNaK09MNnkydThUMmV2SzJRNjJEOW9uQmJZaGptZW8yMC82eFcweDlpTkpnZWNNNDlNWU5TRlMrOEd4SUl1em9ueHlQTzB0ZUMzbi81eDlVazY0UGVpZzJKaERnUCtXc2FFcHNUbGVjdGRBR1RBSWIwWGJjVnhsN1VHVUE4d3J4eTMyWDFzTUhDU09ZeCtpZXczV2E5QzlvK3p2d0ZodjdIdlVON2NqTm5LODJ2WUxMdCtva1hNQXp1Yks4RkswcmMwdXMvSWdHcjlzZXhaZUUraG5rUHQwS2dFMkhXMHhQbS9kdVhzVVdIZWFDOUc4SzI4UEJyNjJray9odFNuckl6UVh4emtIM1R1Z0Q5d1h0dG1zdGNMSTg2TXF3U0I3RnRZRDRqV1hnOUQ0eWwxcis5MFg2OGJWVXoxZzc1d1VHM09Sb242NGxiK0RBWXJrcitOaWM2NkV4N0xGSlk0N0c5K2MzOVZGc2YyUzFwZUpmV1Z5ZStESGRqK1lGd3RwUE9IYVFmd2FJeWpqK3pWeUxmYmZMUDV0NHd6RHpqaGJ5OUkzR1dQajUrWTgyVlc5aE1ReCtCemVndCtTb1dNK1psZDlJcjNWUjdKdHZyOTRjRWtHb2RQMmUwL2Q4T3RGMVROZm5NUW5ydU1UTStqRVlqemdobGxVQS8vTkxNd2tudjdlOS9xL0R4LytkN1RmY044SHNmR0RlTFcyRE9Yc3EwQmZJdFkvaXJlaHV3bC9MWjY5N216dm9VUnZmUEdlZ0ZUTXhMMzkraWFRWHNlTlA4U2F1b1lRWnJ1cnROTGp1TXQ0eEFyTUM1Z2JWMTdITWQ5eEhITmwwM3pTYzBicnVLN2k3RnJnZVBDOXdwcXU3YzJHZm1pNHJiVjhGMnI2My92NzdmOEtWMkFpNTJZQUFBPT0ifQ== -->

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["Location"],"name":[1],"type":["fctr"],"align":["left"]},{"label":["RankNadal"],"name":[2],"type":["dbl"],"align":["right"]},{"label":["PartidosUlt6Meses"],"name":[3],"type":["int"],"align":["right"]},{"label":["PartidosUlt3Meses"],"name":[4],"type":["int"],"align":["right"]},{"label":["PartidosUltMes"],"name":[5],"type":["int"],"align":["right"]}],"data":[{"1":"Doha","2":"51","3":"1","4":"1","5":"1"},{"1":"Doha","2":"51","3":"2","4":"2","5":"2"},{"1":"Doha","2":"51","3":"3","4":"3","5":"3"},{"1":"Auckland","2":"50","3":"4","4":"4","5":"4"},{"1":"Melbourne","2":"56","3":"5","4":"5","5":"5"},{"1":"Melbourne","2":"56","3":"6","4":"6","5":"6"},{"1":"Melbourne","2":"56","3":"7","4":"7","5":"7"},{"1":"Melbourne","2":"56","3":"8","4":"8","5":"8"},{"1":"Buenos Aires","2":"48","3":"9","4":"9","5":"6"},{"1":"Buenos Aires","2":"48","3":"10","4":"10","5":"6"},{"1":"Buenos Aires","2":"48","3":"11","4":"11","5":"7"},{"1":"Costa Do Sauipe","2":"48","3":"12","4":"12","5":"8"},{"1":"Costa Do Sauipe","2":"48","3":"14","4":"14","5":"9"},{"1":"Costa Do Sauipe","2":"48","3":"14","4":"14","5":"9"},{"1":"Costa Do Sauipe","2":"48","3":"15","4":"15","5":"9"},{"1":"Costa Do Sauipe","2":"48","3":"16","4":"16","5":"10"},{"1":"Acapulco","2":"39","3":"17","4":"17","5":"10"},{"1":"Acapulco","2":"39","3":"18","4":"18","5":"10"},{"1":"Acapulco","2":"39","3":"19","4":"19","5":"11"},{"1":"Acapulco","2":"39","3":"20","4":"20","5":"12"},{"1":"Acapulco","2":"39","3":"21","4":"21","5":"13"},{"1":"Miami","2":"31","3":"22","4":"22","5":"4"},{"1":"Miami","2":"31","3":"23","4":"23","5":"4"},{"1":"Miami","2":"31","3":"24","4":"24","5":"3"},{"1":"Miami","2":"31","3":"25","4":"25","5":"4"},{"1":"Miami","2":"31","3":"26","4":"26","5":"5"},{"1":"Miami","2":"31","3":"27","4":"27","5":"6"},{"1":"Valencia","2":"17","3":"28","4":"25","5":"7"},{"1":"Valencia","2":"17","3":"29","4":"26","5":"8"},{"1":"Valencia","2":"17","3":"30","4":"27","5":"9"},{"1":"Monte Carlo","2":"17","3":"31","4":"27","5":"10"},{"1":"Monte Carlo","2":"17","3":"32","4":"28","5":"11"},{"1":"Monte Carlo","2":"17","3":"33","4":"29","5":"12"},{"1":"Monte Carlo","2":"17","3":"34","4":"30","5":"13"},{"1":"Monte Carlo","2":"17","3":"35","4":"31","5":"14"},{"1":"Monte Carlo","2":"17","3":"36","4":"32","5":"15"},{"1":"Barcelona","2":"11","3":"37","4":"31","5":"16"},{"1":"Barcelona","2":"11","3":"38","4":"32","5":"17"},{"1":"Barcelona","2":"11","3":"39","4":"32","5":"18"},{"1":"Barcelona","2":"11","3":"40","4":"33","5":"19"},{"1":"Barcelona","2":"11","3":"41","4":"33","5":"19"},{"1":"Rome","2":"7","3":"42","4":"34","5":"15"},{"1":"Rome","2":"7","3":"43","4":"35","5":"16"},{"1":"Rome","2":"7","3":"44","4":"36","5":"17"},{"1":"Rome","2":"7","3":"45","4":"37","5":"17"},{"1":"Rome","2":"7","3":"46","4":"38","5":"17"},{"1":"Rome","2":"7","3":"47","4":"39","5":"17"},{"1":"Paris","2":"5","3":"48","4":"31","5":"8"},{"1":"Paris","2":"5","3":"49","4":"31","5":"8"},{"1":"Paris","2":"5","3":"50","4":"30","5":"9"},{"1":"Paris","2":"5","3":"51","4":"30","5":"10"},{"1":"Paris","2":"5","3":"52","4":"31","5":"11"},{"1":"Paris","2":"5","3":"53","4":"32","5":"10"},{"1":"Paris","2":"5","3":"54","4":"33","5":"9"},{"1":"Halle","2":"3","3":"55","4":"34","5":"8"},{"1":"London","2":"3","3":"56","4":"35","5":"9"},{"1":"London","2":"3","3":"57","4":"35","5":"9"},{"1":"Bastad","2":"3","3":"55","4":"30","5":"4"},{"1":"Bastad","2":"3","3":"56","4":"29","5":"5"},{"1":"Bastad","2":"3","3":"57","4":"30","5":"5"},{"1":"Bastad","2":"3","3":"58","4":"31","5":"6"},{"1":"Bastad","2":"3","3":"58","4":"31","5":"7"},{"1":"Stuttgart","2":"3","3":"57","4":"25","5":"8"},{"1":"Stuttgart","2":"3","3":"57","4":"25","5":"8"},{"1":"Stuttgart","2":"3","3":"58","4":"25","5":"9"},{"1":"Stuttgart","2":"3","3":"58","4":"25","5":"9"},{"1":"Stuttgart","2":"3","3":"59","4":"26","5":"10"},{"1":"Montreal","2":"2","3":"58","4":"21","5":"6"},{"1":"Montreal","2":"2","3":"59","4":"23","5":"8"},{"1":"Montreal","2":"2","3":"59","4":"23","5":"8"},{"1":"Montreal","2":"2","3":"60","4":"24","5":"9"},{"1":"Montreal","2":"2","3":"62","4":"26","5":"11"},{"1":"Montreal","2":"2","3":"62","4":"26","5":"11"},{"1":"Cincinnati","2":"2","3":"60","4":"27","5":"12"},{"1":"New York","2":"2","3":"54","4":"23","5":"8"},{"1":"New York","2":"2","3":"55","4":"23","5":"9"},{"1":"New York","2":"2","3":"56","4":"23","5":"10"},{"1":"Beijing","2":"2","3":"57","4":"23","5":"5"},{"1":"Beijing","2":"2","3":"59","4":"25","5":"6"},{"1":"Beijing","2":"2","3":"59","4":"25","5":"6"},{"1":"Beijing","2":"2","3":"60","4":"26","5":"7"},{"1":"Beijing","2":"2","3":"61","4":"27","5":"8"},{"1":"Madrid","2":"2","3":"44","4":"19","5":"1"},{"1":"Madrid","2":"2","3":"44","4":"19","5":"2"},{"1":"Madrid","2":"2","3":"44","4":"19","5":"3"},{"1":"Madrid","2":"2","3":"45","4":"19","5":"4"},{"1":"Madrid","2":"2","3":"46","4":"20","5":"5"},{"1":"Marseille","2":"2","3":"14","4":"1","5":"1"},{"1":"Marseille","2":"2","3":"15","4":"2","5":"2"},{"1":"Marseille","2":"2","3":"16","4":"3","5":"3"},{"1":"Marseille","2":"2","3":"17","4":"4","5":"4"},{"1":"Dubai","2":"2","3":"16","4":"5","5":"5"},{"1":"Dubai","2":"2","3":"17","4":"6","5":"6"},{"1":"Dubai","2":"2","3":"17","4":"7","5":"7"},{"1":"Dubai","2":"2","3":"18","4":"8","5":"8"},{"1":"Dubai","2":"2","3":"19","4":"9","5":"9"},{"1":"Indian Wells","2":"2","3":"20","4":"10","5":"10"},{"1":"Indian Wells","2":"2","3":"18","4":"11","5":"11"},{"1":"Indian Wells","2":"2","3":"18","4":"12","5":"11"},{"1":"Indian Wells","2":"2","3":"18","4":"13","5":"11"},{"1":"Indian Wells","2":"2","3":"19","4":"14","5":"11"},{"1":"Miami","2":"2","3":"20","4":"15","5":"11"},{"1":"Monte Carlo","2":"2","3":"19","4":"16","5":"2"},{"1":"Monte Carlo","2":"2","3":"19","4":"17","5":"3"},{"1":"Monte Carlo","2":"2","3":"19","4":"18","5":"4"},{"1":"Monte Carlo","2":"2","3":"19","4":"19","5":"5"},{"1":"Monte Carlo","2":"2","3":"20","4":"20","5":"6"},{"1":"Monte Carlo","2":"2","3":"21","4":"21","5":"6"},{"1":"Barcelona","2":"2","3":"22","4":"22","5":"7"},{"1":"Barcelona","2":"2","3":"23","4":"23","5":"8"},{"1":"Barcelona","2":"2","3":"24","4":"24","5":"9"},{"1":"Barcelona","2":"2","3":"25","4":"25","5":"10"},{"1":"Barcelona","2":"2","3":"26","4":"26","5":"11"},{"1":"Rome","2":"2","3":"27","4":"27","5":"12"},{"1":"Rome","2":"2","3":"28","4":"28","5":"13"},{"1":"Rome","2":"2","3":"29","4":"29","5":"14"},{"1":"Rome","2":"2","3":"30","4":"30","5":"15"},{"1":"Rome","2":"2","3":"31","4":"31","5":"16"},{"1":"Rome","2":"2","3":"32","4":"32","5":"17"},{"1":"Paris","2":"2","3":"33","4":"28","5":"8"},{"1":"Paris","2":"2","3":"34","4":"25","5":"8"},{"1":"Paris","2":"2","3":"35","4":"26","5":"9"},{"1":"Paris","2":"2","3":"36","4":"27","5":"10"},{"1":"Paris","2":"2","3":"37","4":"28","5":"11"},{"1":"Paris","2":"2","3":"38","4":"29","5":"10"},{"1":"Paris","2":"2","3":"39","4":"29","5":"9"},{"1":"Queens Club","2":"2","3":"40","4":"28","5":"8"},{"1":"Queens Club","2":"2","3":"41","4":"29","5":"9"},{"1":"Queens Club","2":"2","3":"42","4":"29","5":"10"},{"1":"London","2":"2","3":"43","4":"28","5":"11"},{"1":"London","2":"2","3":"44","4":"29","5":"11"},{"1":"London","2":"2","3":"45","4":"30","5":"12"},{"1":"London","2":"2","3":"46","4":"31","5":"11"},{"1":"London","2":"2","3":"47","4":"32","5":"11"},{"1":"London","2":"2","3":"48","4":"33","5":"11"},{"1":"London","2":"2","3":"49","4":"34","5":"11"},{"1":"Toronto","2":"2","3":"50","4":"22","5":"1"},{"1":"Toronto","2":"2","3":"52","4":"22","5":"3"},{"1":"Toronto","2":"2","3":"52","4":"22","5":"3"},{"1":"Cincinnati","2":"2","3":"51","4":"21","5":"4"},{"1":"Cincinnati","2":"2","3":"51","4":"22","5":"5"},{"1":"Cincinnati","2":"2","3":"51","4":"23","5":"6"},{"1":"Cincinnati","2":"2","3":"52","4":"24","5":"7"},{"1":"New York","2":"2","3":"49","4":"24","5":"8"},{"1":"New York","2":"2","3":"49","4":"24","5":"9"},{"1":"New York","2":"2","3":"50","4":"23","5":"10"},{"1":"New York","2":"2","3":"51","4":"24","5":"11"},{"1":"New York","2":"2","3":"52","4":"24","5":"12"},{"1":"Stockholm","2":"2","3":"47","4":"13","5":"1"},{"1":"Stockholm","2":"2","3":"48","4":"14","5":"2"},{"1":"Madrid","2":"2","3":"45","4":"15","5":"3"},{"1":"Madrid","2":"2","3":"45","4":"16","5":"4"},{"1":"Madrid","2":"2","3":"45","4":"17","5":"5"},{"1":"Shanghai","2":"2","3":"35","4":"14","5":"4"},{"1":"Shanghai","2":"2","3":"36","4":"13","5":"5"},{"1":"Shanghai","2":"2","3":"37","4":"13","5":"5"},{"1":"Shanghai","2":"2","3":"38","4":"14","5":"5"},{"1":"Chennai","2":"2","3":"24","4":"10","5":"1"},{"1":"Chennai","2":"2","3":"24","4":"11","5":"2"},{"1":"Chennai","2":"2","3":"24","4":"12","5":"3"},{"1":"Chennai","2":"2","3":"25","4":"13","5":"4"},{"1":"Sydney","2":"2","3":"26","4":"12","5":"5"},{"1":"Melbourne","2":"2","3":"27","4":"12","5":"6"},{"1":"Melbourne","2":"2","3":"28","4":"11","5":"7"},{"1":"Melbourne","2":"2","3":"29","4":"12","5":"8"},{"1":"Melbourne","2":"2","3":"30","4":"13","5":"9"},{"1":"Melbourne","2":"2","3":"31","4":"14","5":"10"},{"1":"Dubai","2":"2","3":"23","4":"11","5":"1"},{"1":"Dubai","2":"2","3":"24","4":"12","5":"2"},{"1":"Dubai","2":"2","3":"25","4":"13","5":"3"},{"1":"Indian Wells","2":"2","3":"23","4":"14","5":"4"},{"1":"Indian Wells","2":"2","3":"25","4":"16","5":"6"},{"1":"Indian Wells","2":"2","3":"25","4":"16","5":"6"},{"1":"Indian Wells","2":"2","3":"26","4":"17","5":"7"},{"1":"Indian Wells","2":"2","3":"27","4":"18","5":"8"},{"1":"Indian Wells","2":"2","3":"28","4":"19","5":"9"},{"1":"Miami","2":"2","3":"29","4":"20","5":"10"},{"1":"Miami","2":"2","3":"30","4":"21","5":"11"},{"1":"Miami","2":"2","3":"31","4":"22","5":"12"},{"1":"Miami","2":"2","3":"32","4":"23","5":"12"},{"1":"Monte Carlo","2":"2","3":"28","4":"17","5":"5"},{"1":"Monte Carlo","2":"2","3":"29","4":"18","5":"6"},{"1":"Monte Carlo","2":"2","3":"30","4":"18","5":"7"},{"1":"Monte Carlo","2":"2","3":"31","4":"19","5":"8"},{"1":"Monte Carlo","2":"2","3":"32","4":"19","5":"8"},{"1":"Barcelona","2":"2","3":"33","4":"19","5":"8"},{"1":"Barcelona","2":"2","3":"34","4":"20","5":"9"},{"1":"Barcelona","2":"2","3":"35","4":"21","5":"9"},{"1":"Barcelona","2":"2","3":"36","4":"22","5":"9"},{"1":"Barcelona","2":"2","3":"37","4":"23","5":"10"},{"1":"Rome","2":"2","3":"38","4":"24","5":"11"},{"1":"Rome","2":"2","3":"39","4":"25","5":"12"},{"1":"Rome","2":"2","3":"40","4":"26","5":"13"},{"1":"Rome","2":"2","3":"40","4":"27","5":"14"},{"1":"Rome","2":"2","3":"41","4":"28","5":"15"},{"1":"Hamburg","2":"2","3":"40","4":"29","5":"16"},{"1":"Hamburg","2":"2","3":"40","4":"30","5":"17"},{"1":"Hamburg","2":"2","3":"41","4":"31","5":"17"},{"1":"Hamburg","2":"2","3":"42","4":"32","5":"17"},{"1":"Hamburg","2":"2","3":"43","4":"33","5":"17"},{"1":"Paris","2":"2","3":"44","4":"32","5":"11"},{"1":"Paris","2":"2","3":"45","4":"32","5":"12"},{"1":"Paris","2":"2","3":"46","4":"33","5":"13"},{"1":"Paris","2":"2","3":"47","4":"34","5":"14"},{"1":"Paris","2":"2","3":"48","4":"35","5":"15"},{"1":"Paris","2":"2","3":"49","4":"35","5":"15"},{"1":"Paris","2":"2","3":"50","4":"36","5":"14"},{"1":"Queens Club","2":"2","3":"51","4":"34","5":"13"},{"1":"Queens Club","2":"2","3":"53","4":"35","5":"14"},{"1":"Queens Club","2":"2","3":"53","4":"35","5":"14"},{"1":"London","2":"2","3":"54","4":"32","5":"11"},{"1":"London","2":"2","3":"55","4":"32","5":"11"},{"1":"London","2":"2","3":"53","4":"33","5":"9"},{"1":"London","2":"2","3":"53","4":"34","5":"10"},{"1":"London","2":"2","3":"54","4":"35","5":"10"},{"1":"London","2":"2","3":"55","4":"36","5":"11"},{"1":"London","2":"2","3":"55","4":"37","5":"11"},{"1":"Stuttgart","2":"2","3":"54","4":"37","5":"8"},{"1":"Stuttgart","2":"2","3":"54","4":"36","5":"9"},{"1":"Stuttgart","2":"2","3":"55","4":"36","5":"10"},{"1":"Stuttgart","2":"2","3":"55","4":"36","5":"11"},{"1":"Stuttgart","2":"2","3":"56","4":"37","5":"12"},{"1":"Montreal","2":"2","3":"57","4":"31","5":"7"},{"1":"Montreal","2":"2","3":"57","4":"31","5":"7"},{"1":"Montreal","2":"2","3":"58","4":"30","5":"8"},{"1":"Montreal","2":"2","3":"59","4":"31","5":"9"},{"1":"Cincinnati","2":"2","3":"60","4":"30","5":"10"},{"1":"New York","2":"2","3":"58","4":"26","5":"6"},{"1":"New York","2":"2","3":"59","4":"26","5":"7"},{"1":"New York","2":"2","3":"60","4":"26","5":"8"},{"1":"New York","2":"2","3":"61","4":"26","5":"9"},{"1":"Madrid","2":"2","3":"49","4":"13","5":"1"},{"1":"Madrid","2":"2","3":"49","4":"13","5":"2"},{"1":"Madrid","2":"2","3":"49","4":"13","5":"3"},{"1":"Paris","2":"2","3":"45","4":"13","5":"4"},{"1":"Paris","2":"2","3":"46","4":"14","5":"5"},{"1":"Paris","2":"2","3":"47","4":"15","5":"6"},{"1":"Paris","2":"2","3":"48","4":"16","5":"7"},{"1":"Paris","2":"2","3":"49","4":"17","5":"8"},{"1":"Shanghai","2":"2","3":"45","4":"14","5":"9"},{"1":"Shanghai","2":"2","3":"44","4":"14","5":"10"},{"1":"Shanghai","2":"2","3":"43","4":"15","5":"11"},{"1":"Shanghai","2":"2","3":"43","4":"16","5":"10"},{"1":"Chennai","2":"2","3":"30","4":"13","5":"1"},{"1":"Chennai","2":"2","3":"29","4":"14","5":"2"},{"1":"Chennai","2":"2","3":"29","4":"15","5":"3"},{"1":"Chennai","2":"2","3":"30","4":"16","5":"4"},{"1":"Chennai","2":"2","3":"31","4":"17","5":"5"},{"1":"Melbourne","2":"2","3":"31","4":"18","5":"6"},{"1":"Melbourne","2":"2","3":"30","4":"17","5":"7"},{"1":"Melbourne","2":"2","3":"29","4":"17","5":"8"},{"1":"Melbourne","2":"2","3":"30","4":"18","5":"9"},{"1":"Melbourne","2":"2","3":"31","4":"19","5":"10"},{"1":"Melbourne","2":"2","3":"32","4":"20","5":"11"},{"1":"Rotterdam","2":"2","3":"28","4":"12","5":"3"},{"1":"Rotterdam","2":"2","3":"29","4":"13","5":"3"},{"1":"Dubai","2":"2","3":"26","4":"14","5":"3"},{"1":"Dubai","2":"2","3":"27","4":"15","5":"4"},{"1":"Dubai","2":"2","3":"28","4":"16","5":"5"},{"1":"Indian Wells","2":"2","3":"29","4":"17","5":"6"},{"1":"Indian Wells","2":"2","3":"30","4":"18","5":"7"},{"1":"Indian Wells","2":"2","3":"31","4":"19","5":"8"},{"1":"Indian Wells","2":"2","3":"32","4":"20","5":"8"},{"1":"Indian Wells","2":"2","3":"33","4":"21","5":"8"},{"1":"Miami","2":"2","3":"34","4":"22","5":"9"},{"1":"Miami","2":"2","3":"35","4":"23","5":"10"},{"1":"Miami","2":"2","3":"36","4":"23","5":"11"},{"1":"Miami","2":"2","3":"37","4":"23","5":"12"},{"1":"Miami","2":"2","3":"38","4":"22","5":"11"},{"1":"Miami","2":"2","3":"39","4":"22","5":"11"},{"1":"Monte Carlo","2":"2","3":"37","4":"17","5":"7"},{"1":"Monte Carlo","2":"2","3":"38","4":"18","5":"8"},{"1":"Monte Carlo","2":"2","3":"39","4":"19","5":"9"},{"1":"Monte Carlo","2":"2","3":"40","4":"20","5":"10"},{"1":"Monte Carlo","2":"2","3":"41","4":"21","5":"10"},{"1":"Barcelona","2":"2","3":"39","4":"22","5":"10"},{"1":"Barcelona","2":"2","3":"39","4":"23","5":"10"},{"1":"Barcelona","2":"2","3":"39","4":"24","5":"10"},{"1":"Barcelona","2":"2","3":"40","4":"25","5":"11"},{"1":"Barcelona","2":"2","3":"41","4":"26","5":"11"},{"1":"Rome","2":"2","3":"42","4":"27","5":"11"},{"1":"Hamburg","2":"2","3":"40","4":"28","5":"12"},{"1":"Hamburg","2":"2","3":"40","4":"29","5":"13"},{"1":"Hamburg","2":"2","3":"41","4":"30","5":"14"},{"1":"Hamburg","2":"2","3":"42","4":"31","5":"15"},{"1":"Hamburg","2":"2","3":"43","4":"32","5":"16"},{"1":"Paris","2":"2","3":"44","4":"31","5":"12"},{"1":"Paris","2":"2","3":"45","4":"32","5":"13"},{"1":"Paris","2":"2","3":"46","4":"33","5":"13"},{"1":"Paris","2":"2","3":"47","4":"34","5":"12"},{"1":"Paris","2":"2","3":"48","4":"33","5":"11"},{"1":"Paris","2":"2","3":"49","4":"33","5":"11"},{"1":"Paris","2":"2","3":"50","4":"34","5":"12"},{"1":"Queens Club","2":"2","3":"51","4":"35","5":"13"},{"1":"Queens Club","2":"2","3":"52","4":"36","5":"14"},{"1":"Queens Club","2":"2","3":"53","4":"36","5":"14"},{"1":"Queens Club","2":"2","3":"54","4":"37","5":"14"},{"1":"Queens Club","2":"2","3":"55","4":"37","5":"14"},{"1":"London","2":"2","3":"56","4":"35","5":"13"},{"1":"London","2":"2","3":"57","4":"35","5":"14"},{"1":"London","2":"2","3":"58","4":"35","5":"13"},{"1":"London","2":"2","3":"58","4":"35","5":"13"},{"1":"London","2":"2","3":"57","4":"35","5":"13"},{"1":"London","2":"2","3":"56","4":"35","5":"13"},{"1":"London","2":"2","3":"57","4":"35","5":"13"},{"1":"Toronto","2":"2","3":"52","4":"33","5":"7"},{"1":"Toronto","2":"2","3":"53","4":"33","5":"8"},{"1":"Toronto","2":"2","3":"54","4":"33","5":"8"},{"1":"Toronto","2":"2","3":"56","4":"35","5":"10"},{"1":"Toronto","2":"2","3":"56","4":"35","5":"10"},{"1":"Cincinnati","2":"2","3":"57","4":"33","5":"9"},{"1":"Cincinnati","2":"2","3":"58","4":"33","5":"9"},{"1":"Cincinnati","2":"2","3":"59","4":"33","5":"10"},{"1":"Cincinnati","2":"2","3":"60","4":"34","5":"10"},{"1":"New York","2":"1","3":"59","4":"29","5":"7"},{"1":"New York","2":"1","3":"60","4":"27","5":"6"},{"1":"New York","2":"1","3":"61","4":"27","5":"6"},{"1":"New York","2":"1","3":"60","4":"27","5":"5"},{"1":"New York","2":"1","3":"60","4":"27","5":"5"},{"1":"New York","2":"1","3":"61","4":"27","5":"6"},{"1":"Madrid","2":"1","3":"51","4":"16","5":"1"},{"1":"Madrid","2":"1","3":"52","4":"17","5":"2"},{"1":"Madrid","2":"1","3":"53","4":"18","5":"3"},{"1":"Madrid","2":"1","3":"54","4":"19","5":"4"},{"1":"Paris","2":"1","3":"47","4":"14","5":"5"},{"1":"Paris","2":"1","3":"47","4":"14","5":"6"},{"1":"Paris","2":"1","3":"47","4":"14","5":"7"},{"1":"Doha","2":"1","3":"23","4":"8","5":"1"},{"1":"Doha","2":"1","3":"24","4":"9","5":"2"},{"1":"Doha","2":"1","3":"25","4":"10","5":"3"},{"1":"Melbourne","2":"1","3":"25","4":"7","5":"4"},{"1":"Melbourne","2":"1","3":"24","4":"8","5":"5"},{"1":"Melbourne","2":"1","3":"23","4":"9","5":"6"},{"1":"Melbourne","2":"1","3":"24","4":"10","5":"7"},{"1":"Melbourne","2":"1","3":"23","4":"9","5":"8"},{"1":"Melbourne","2":"1","3":"22","4":"9","5":"9"},{"1":"Melbourne","2":"1","3":"23","4":"10","5":"10"},{"1":"Rotterdam","2":"1","3":"24","4":"11","5":"8"},{"1":"Rotterdam","2":"1","3":"25","4":"12","5":"9"},{"1":"Rotterdam","2":"1","3":"26","4":"13","5":"10"},{"1":"Rotterdam","2":"1","3":"27","4":"14","5":"11"},{"1":"Rotterdam","2":"1","3":"28","4":"15","5":"12"},{"1":"Indian Wells","2":"1","3":"23","4":"16","5":"2"},{"1":"Indian Wells","2":"1","3":"24","4":"17","5":"2"},{"1":"Indian Wells","2":"1","3":"25","4":"18","5":"3"},{"1":"Indian Wells","2":"1","3":"26","4":"19","5":"4"},{"1":"Indian Wells","2":"1","3":"27","4":"20","5":"5"},{"1":"Indian Wells","2":"1","3":"28","4":"21","5":"6"},{"1":"Miami","2":"1","3":"29","4":"22","5":"7"},{"1":"Miami","2":"1","3":"30","4":"23","5":"8"},{"1":"Miami","2":"1","3":"31","4":"24","5":"9"},{"1":"Miami","2":"1","3":"32","4":"25","5":"10"},{"1":"Monte Carlo","2":"1","3":"30","4":"23","5":"10"},{"1":"Monte Carlo","2":"1","3":"31","4":"25","5":"11"},{"1":"Monte Carlo","2":"1","3":"31","4":"25","5":"11"},{"1":"Monte Carlo","2":"1","3":"32","4":"26","5":"11"},{"1":"Monte Carlo","2":"1","3":"33","4":"27","5":"11"},{"1":"Barcelona","2":"1","3":"34","4":"26","5":"10"},{"1":"Barcelona","2":"1","3":"35","4":"27","5":"11"},{"1":"Barcelona","2":"1","3":"36","4":"27","5":"12"},{"1":"Barcelona","2":"1","3":"37","4":"28","5":"13"},{"1":"Barcelona","2":"1","3":"38","4":"28","5":"14"},{"1":"Rome","2":"1","3":"36","4":"28","5":"13"},{"1":"Rome","2":"1","3":"37","4":"28","5":"14"},{"1":"Rome","2":"1","3":"38","4":"29","5":"14"},{"1":"Rome","2":"1","3":"39","4":"29","5":"14"},{"1":"Rome","2":"1","3":"40","4":"30","5":"15"},{"1":"Madrid","2":"1","3":"41","4":"29","5":"16"},{"1":"Madrid","2":"1","3":"42","4":"29","5":"17"},{"1":"Madrid","2":"1","3":"43","4":"29","5":"17"},{"1":"Madrid","2":"1","3":"44","4":"29","5":"18"},{"1":"Madrid","2":"1","3":"45","4":"30","5":"17"},{"1":"Paris","2":"1","3":"46","4":"31","5":"12"},{"1":"Paris","2":"1","3":"47","4":"32","5":"12"},{"1":"Paris","2":"1","3":"48","4":"33","5":"12"},{"1":"Paris","2":"1","3":"49","4":"34","5":"11"},{"1":"Montreal","2":"2","3":"37","4":"8","5":"1"},{"1":"Montreal","2":"2","3":"37","4":"8","5":"2"},{"1":"Montreal","2":"2","3":"37","4":"7","5":"3"},{"1":"Cincinnati","2":"3","3":"38","4":"8","5":"4"},{"1":"Cincinnati","2":"3","3":"39","4":"9","5":"5"},{"1":"Cincinnati","2":"3","3":"40","4":"10","5":"6"},{"1":"Cincinnati","2":"3","3":"41","4":"11","5":"7"},{"1":"New York","2":"3","3":"42","4":"8","5":"8"},{"1":"New York","2":"3","3":"43","4":"9","5":"9"},{"1":"New York","2":"3","3":"44","4":"10","5":"10"},{"1":"New York","2":"3","3":"45","4":"11","5":"11"},{"1":"New York","2":"3","3":"45","4":"12","5":"10"},{"1":"New York","2":"3","3":"46","4":"13","5":"11"},{"1":"Beijing","2":"2","3":"38","4":"14","5":"4"},{"1":"Beijing","2":"2","3":"39","4":"15","5":"5"},{"1":"Beijing","2":"2","3":"40","4":"16","5":"5"},{"1":"Beijing","2":"2","3":"41","4":"17","5":"6"},{"1":"Shanghai","2":"2","3":"39","4":"18","5":"5"},{"1":"Shanghai","2":"2","3":"39","4":"19","5":"6"},{"1":"Shanghai","2":"2","3":"39","4":"20","5":"7"},{"1":"Shanghai","2":"2","3":"40","4":"21","5":"8"},{"1":"Shanghai","2":"2","3":"41","4":"22","5":"9"},{"1":"Paris","2":"2","3":"29","4":"21","5":"6"},{"1":"Paris","2":"2","3":"29","4":"22","5":"7"},{"1":"Paris","2":"2","3":"29","4":"22","5":"7"},{"1":"Paris","2":"2","3":"30","4":"23","5":"7"},{"1":"London","2":"2","3":"29","4":"20","5":"5"},{"1":"London","2":"2","3":"29","4":"21","5":"6"},{"1":"London","2":"2","3":"29","4":"22","5":"7"},{"1":"Doha","2":"2","3":"30","4":"16","5":"1"},{"1":"Doha","2":"2","3":"31","4":"16","5":"2"},{"1":"Doha","2":"2","3":"32","4":"16","5":"3"},{"1":"Doha","2":"2","3":"33","4":"16","5":"4"},{"1":"Doha","2":"2","3":"34","4":"17","5":"5"},{"1":"Melbourne","2":"2","3":"35","4":"13","5":"6"},{"1":"Melbourne","2":"2","3":"36","4":"14","5":"7"},{"1":"Melbourne","2":"2","3":"37","4":"15","5":"8"},{"1":"Melbourne","2":"2","3":"38","4":"16","5":"9"},{"1":"Melbourne","2":"2","3":"39","4":"17","5":"10"},{"1":"Indian Wells","2":"3","3":"27","4":"11","5":"1"},{"1":"Indian Wells","2":"3","3":"28","4":"12","5":"2"},{"1":"Indian Wells","2":"3","3":"29","4":"13","5":"3"},{"1":"Indian Wells","2":"3","3":"30","4":"14","5":"4"},{"1":"Indian Wells","2":"3","3":"31","4":"15","5":"5"},{"1":"Miami","2":"4","3":"32","4":"16","5":"6"},{"1":"Miami","2":"4","3":"33","4":"17","5":"7"},{"1":"Miami","2":"4","3":"34","4":"18","5":"8"},{"1":"Miami","2":"4","3":"35","4":"19","5":"9"},{"1":"Miami","2":"4","3":"36","4":"20","5":"10"},{"1":"Monte Carlo","2":"3","3":"30","4":"16","5":"9"},{"1":"Monte Carlo","2":"3","3":"30","4":"17","5":"10"},{"1":"Monte Carlo","2":"3","3":"30","4":"18","5":"10"},{"1":"Monte Carlo","2":"3","3":"31","4":"19","5":"11"},{"1":"Monte Carlo","2":"3","3":"32","4":"19","5":"11"},{"1":"Rome","2":"3","3":"33","4":"16","5":"9"},{"1":"Rome","2":"3","3":"34","4":"17","5":"9"},{"1":"Rome","2":"3","3":"35","4":"18","5":"10"},{"1":"Rome","2":"3","3":"36","4":"19","5":"10"},{"1":"Rome","2":"3","3":"37","4":"20","5":"10"},{"1":"Madrid","2":"3","3":"35","4":"21","5":"11"},{"1":"Madrid","2":"3","3":"35","4":"22","5":"12"},{"1":"Madrid","2":"3","3":"36","4":"23","5":"12"},{"1":"Madrid","2":"3","3":"37","4":"24","5":"12"},{"1":"Madrid","2":"3","3":"38","4":"25","5":"12"},{"1":"Paris","2":"2","3":"37","4":"26","5":"11"},{"1":"Paris","2":"2","3":"37","4":"27","5":"11"},{"1":"Paris","2":"2","3":"38","4":"28","5":"11"},{"1":"Paris","2":"2","3":"39","4":"29","5":"10"},{"1":"Paris","2":"2","3":"40","4":"30","5":"10"},{"1":"Paris","2":"2","3":"41","4":"31","5":"11"},{"1":"Paris","2":"2","3":"42","4":"32","5":"12"},{"1":"Queens Club","2":"1","3":"43","4":"33","5":"13"},{"1":"Queens Club","2":"1","3":"44","4":"34","5":"14"},{"1":"Queens Club","2":"1","3":"45","4":"35","5":"14"},{"1":"London","2":"1","3":"46","4":"31","5":"11"},{"1":"London","2":"1","3":"47","4":"31","5":"11"},{"1":"London","2":"1","3":"48","4":"31","5":"12"},{"1":"London","2":"1","3":"49","4":"31","5":"11"},{"1":"London","2":"1","3":"50","4":"31","5":"11"},{"1":"London","2":"1","3":"51","4":"31","5":"11"},{"1":"London","2":"1","3":"51","4":"32","5":"11"},{"1":"Toronto","2":"1","3":"43","4":"21","5":"1"},{"1":"Toronto","2":"1","3":"44","4":"21","5":"2"},{"1":"Toronto","2":"1","3":"45","4":"21","5":"3"},{"1":"Toronto","2":"1","3":"46","4":"21","5":"4"},{"1":"Cincinnati","2":"1","3":"47","4":"22","5":"5"},{"1":"Cincinnati","2":"1","3":"48","4":"23","5":"6"},{"1":"Cincinnati","2":"1","3":"49","4":"24","5":"7"},{"1":"New York","2":"1","3":"50","4":"20","5":"8"},{"1":"New York","2":"1","3":"51","4":"19","5":"9"},{"1":"New York","2":"1","3":"52","4":"20","5":"10"},{"1":"New York","2":"1","3":"53","4":"19","5":"11"},{"1":"New York","2":"1","3":"53","4":"19","5":"11"},{"1":"New York","2":"1","3":"53","4":"20","5":"11"},{"1":"New York","2":"1","3":"54","4":"21","5":"11"},{"1":"Bangkok","2":"1","3":"47","4":"16","5":"8"},{"1":"Bangkok","2":"1","3":"48","4":"17","5":"8"},{"1":"Bangkok","2":"1","3":"49","4":"17","5":"9"},{"1":"Tokyo","2":"1","3":"50","4":"18","5":"8"},{"1":"Tokyo","2":"1","3":"51","4":"19","5":"9"},{"1":"Tokyo","2":"1","3":"52","4":"20","5":"9"},{"1":"Tokyo","2":"1","3":"53","4":"21","5":"10"},{"1":"Tokyo","2":"1","3":"54","4":"22","5":"10"},{"1":"Shanghai","2":"1","3":"52","4":"23","5":"9"},{"1":"Shanghai","2":"1","3":"52","4":"24","5":"10"},{"1":"London","2":"1","3":"41","4":"18","5":"1"},{"1":"London","2":"1","3":"41","4":"19","5":"2"},{"1":"London","2":"1","3":"41","4":"20","5":"3"},{"1":"London","2":"1","3":"41","4":"21","5":"4"},{"1":"London","2":"1","3":"42","4":"22","5":"5"},{"1":"Doha","2":"1","3":"30","4":"12","5":"1"},{"1":"Doha","2":"1","3":"31","4":"12","5":"2"},{"1":"Doha","2":"1","3":"32","4":"12","5":"3"},{"1":"Doha","2":"1","3":"33","4":"12","5":"4"},{"1":"Melbourne","2":"1","3":"34","4":"10","5":"5"},{"1":"Melbourne","2":"1","3":"35","4":"11","5":"6"},{"1":"Melbourne","2":"1","3":"36","4":"12","5":"7"},{"1":"Melbourne","2":"1","3":"37","4":"13","5":"8"},{"1":"Melbourne","2":"1","3":"38","4":"14","5":"9"},{"1":"Indian Wells","2":"1","3":"25","4":"10","5":"1"},{"1":"Indian Wells","2":"1","3":"26","4":"11","5":"2"},{"1":"Indian Wells","2":"1","3":"27","4":"12","5":"3"},{"1":"Indian Wells","2":"1","3":"28","4":"13","5":"4"},{"1":"Indian Wells","2":"1","3":"29","4":"14","5":"5"},{"1":"Indian Wells","2":"1","3":"30","4":"15","5":"6"},{"1":"Miami","2":"1","3":"31","4":"16","5":"7"},{"1":"Miami","2":"1","3":"32","4":"17","5":"8"},{"1":"Miami","2":"1","3":"31","4":"18","5":"9"},{"1":"Miami","2":"1","3":"31","4":"19","5":"10"},{"1":"Miami","2":"1","3":"32","4":"20","5":"11"},{"1":"Miami","2":"1","3":"32","4":"21","5":"12"},{"1":"Monte Carlo","2":"1","3":"27","4":"18","5":"11"},{"1":"Monte Carlo","2":"1","3":"28","4":"19","5":"12"},{"1":"Monte Carlo","2":"1","3":"29","4":"20","5":"13"},{"1":"Monte Carlo","2":"1","3":"30","4":"21","5":"13"},{"1":"Monte Carlo","2":"1","3":"31","4":"22","5":"13"},{"1":"Barcelona","2":"1","3":"32","4":"21","5":"12"},{"1":"Barcelona","2":"1","3":"33","4":"22","5":"13"},{"1":"Barcelona","2":"1","3":"34","4":"22","5":"14"},{"1":"Barcelona","2":"1","3":"35","4":"23","5":"15"},{"1":"Barcelona","2":"1","3":"36","4":"23","5":"16"},{"1":"Madrid","2":"1","3":"37","4":"23","5":"11"},{"1":"Madrid","2":"1","3":"38","4":"24","5":"12"},{"1":"Madrid","2":"1","3":"39","4":"25","5":"13"},{"1":"Madrid","2":"1","3":"40","4":"26","5":"14"},{"1":"Madrid","2":"1","3":"41","4":"27","5":"15"},{"1":"Rome","2":"1","3":"42","4":"28","5":"16"},{"1":"Rome","2":"1","3":"43","4":"29","5":"17"},{"1":"Rome","2":"1","3":"44","4":"30","5":"17"},{"1":"Rome","2":"1","3":"45","4":"31","5":"17"},{"1":"Rome","2":"1","3":"46","4":"32","5":"17"},{"1":"Paris","2":"1","3":"45","4":"33","5":"11"},{"1":"Paris","2":"1","3":"44","4":"34","5":"12"},{"1":"Paris","2":"1","3":"44","4":"35","5":"13"},{"1":"Paris","2":"1","3":"45","4":"36","5":"14"},{"1":"Paris","2":"1","3":"46","4":"37","5":"15"},{"1":"Paris","2":"1","3":"47","4":"38","5":"15"},{"1":"Paris","2":"1","3":"48","4":"39","5":"14"},{"1":"Queens Club","2":"1","3":"49","4":"40","5":"13"},{"1":"Queens Club","2":"1","3":"50","4":"41","5":"14"},{"1":"Queens Club","2":"1","3":"51","4":"42","5":"14"},{"1":"London","2":"1","3":"52","4":"37","5":"11"},{"1":"London","2":"1","3":"53","4":"38","5":"12"},{"1":"London","2":"1","3":"54","4":"38","5":"11"},{"1":"London","2":"1","3":"55","4":"38","5":"11"},{"1":"London","2":"1","3":"56","4":"38","5":"11"},{"1":"London","2":"1","3":"57","4":"37","5":"11"},{"1":"London","2":"1","3":"58","4":"37","5":"12"},{"1":"Montreal","2":"2","3":"50","4":"20","5":"1"},{"1":"Cincinnati","2":"2","3":"51","4":"19","5":"2"},{"1":"Cincinnati","2":"2","3":"52","4":"20","5":"3"},{"1":"Cincinnati","2":"2","3":"53","4":"21","5":"4"},{"1":"New York","2":"2","3":"54","4":"17","5":"5"},{"1":"New York","2":"2","3":"55","4":"17","5":"6"},{"1":"New York","2":"2","3":"56","4":"17","5":"7"},{"1":"New York","2":"2","3":"57","4":"15","5":"8"},{"1":"New York","2":"2","3":"57","4":"16","5":"9"},{"1":"New York","2":"2","3":"57","4":"17","5":"9"},{"1":"New York","2":"2","3":"58","4":"18","5":"10"},{"1":"Tokyo","2":"2","3":"49","4":"12","5":"5"},{"1":"Tokyo","2":"2","3":"50","4":"13","5":"6"},{"1":"Tokyo","2":"2","3":"51","4":"14","5":"7"},{"1":"Tokyo","2":"2","3":"52","4":"15","5":"7"},{"1":"Tokyo","2":"2","3":"53","4":"16","5":"7"},{"1":"Shanghai","2":"2","3":"51","4":"17","5":"6"},{"1":"Shanghai","2":"2","3":"51","4":"18","5":"7"},{"1":"London","2":"2","3":"35","4":"15","5":"1"},{"1":"London","2":"2","3":"35","4":"16","5":"2"},{"1":"London","2":"2","3":"35","4":"17","5":"3"},{"1":"Doha","2":"2","3":"22","4":"10","5":"1"},{"1":"Doha","2":"2","3":"23","4":"10","5":"2"},{"1":"Doha","2":"2","3":"24","4":"10","5":"3"},{"1":"Doha","2":"2","3":"25","4":"10","5":"4"},{"1":"Melbourne","2":"2","3":"26","4":"8","5":"5"},{"1":"Melbourne","2":"2","3":"27","4":"9","5":"6"},{"1":"Melbourne","2":"2","3":"28","4":"10","5":"7"},{"1":"Melbourne","2":"2","3":"29","4":"11","5":"8"},{"1":"Melbourne","2":"2","3":"30","4":"12","5":"9"},{"1":"Melbourne","2":"2","3":"31","4":"13","5":"10"},{"1":"Melbourne","2":"2","3":"32","4":"14","5":"11"},{"1":"Indian Wells","2":"2","3":"22","4":"12","5":"1"},{"1":"Indian Wells","2":"2","3":"23","4":"13","5":"2"},{"1":"Indian Wells","2":"2","3":"24","4":"14","5":"3"},{"1":"Indian Wells","2":"2","3":"25","4":"15","5":"4"},{"1":"Indian Wells","2":"2","3":"26","4":"16","5":"5"},{"1":"Miami","2":"2","3":"27","4":"17","5":"6"},{"1":"Miami","2":"2","3":"28","4":"18","5":"7"},{"1":"Miami","2":"2","3":"29","4":"19","5":"8"},{"1":"Miami","2":"2","3":"30","4":"20","5":"9"},{"1":"Miami","2":"2","3":"31","4":"21","5":"10"},{"1":"Monte Carlo","2":"2","3":"25","4":"16","5":"6"},{"1":"Monte Carlo","2":"2","3":"26","4":"16","5":"7"},{"1":"Monte Carlo","2":"2","3":"27","4":"17","5":"8"},{"1":"Monte Carlo","2":"2","3":"28","4":"17","5":"9"},{"1":"Monte Carlo","2":"2","3":"29","4":"18","5":"10"},{"1":"Barcelona","2":"2","3":"30","4":"17","5":"9"},{"1":"Barcelona","2":"2","3":"31","4":"18","5":"9"},{"1":"Barcelona","2":"2","3":"32","4":"19","5":"10"},{"1":"Barcelona","2":"2","3":"33","4":"19","5":"10"},{"1":"Barcelona","2":"2","3":"34","4":"20","5":"10"},{"1":"Madrid","2":"2","3":"35","4":"21","5":"11"},{"1":"Madrid","2":"2","3":"36","4":"22","5":"12"},{"1":"Rome","2":"3","3":"37","4":"23","5":"13"},{"1":"Rome","2":"3","3":"38","4":"24","5":"14"},{"1":"Rome","2":"3","3":"38","4":"25","5":"14"},{"1":"Rome","2":"3","3":"39","4":"26","5":"14"},{"1":"Rome","2":"3","3":"39","4":"27","5":"13"},{"1":"Paris","2":"2","3":"39","4":"28","5":"8"},{"1":"Paris","2":"2","3":"40","4":"29","5":"9"},{"1":"Paris","2":"2","3":"41","4":"30","5":"10"},{"1":"Paris","2":"2","3":"42","4":"31","5":"11"},{"1":"Paris","2":"2","3":"43","4":"32","5":"12"},{"1":"Paris","2":"2","3":"44","4":"33","5":"12"},{"1":"Paris","2":"2","3":"45","4":"33","5":"12"},{"1":"Halle","2":"2","3":"46","4":"31","5":"13"},{"1":"Halle","2":"2","3":"47","4":"32","5":"13"},{"1":"London","2":"2","3":"48","4":"29","5":"10"},{"1":"London","2":"2","3":"49","4":"28","5":"10"},{"1":"Vina del Mar","2":"5","3":"6","4":"1","5":"1"},{"1":"Vina del Mar","2":"5","3":"7","4":"2","5":"2"},{"1":"Vina del Mar","2":"5","3":"9","4":"4","5":"4"},{"1":"Vina del Mar","2":"5","3":"9","4":"4","5":"4"},{"1":"Sao Paulo","2":"5","3":"10","4":"5","5":"5"},{"1":"Sao Paulo","2":"5","3":"11","4":"6","5":"6"},{"1":"Sao Paulo","2":"5","3":"12","4":"7","5":"7"},{"1":"Sao Paulo","2":"5","3":"13","4":"8","5":"8"},{"1":"Acapulco","2":"5","3":"14","4":"9","5":"9"},{"1":"Acapulco","2":"5","3":"15","4":"10","5":"10"},{"1":"Acapulco","2":"5","3":"16","4":"11","5":"11"},{"1":"Acapulco","2":"5","3":"17","4":"12","5":"12"},{"1":"Acapulco","2":"5","3":"18","4":"13","5":"13"},{"1":"Indian Wells","2":"5","3":"19","4":"14","5":"12"},{"1":"Indian Wells","2":"5","3":"20","4":"15","5":"13"},{"1":"Indian Wells","2":"5","3":"21","4":"16","5":"12"},{"1":"Indian Wells","2":"5","3":"22","4":"17","5":"13"},{"1":"Indian Wells","2":"5","3":"23","4":"18","5":"13"},{"1":"Indian Wells","2":"5","3":"24","4":"19","5":"13"},{"1":"Monte Carlo","2":"5","3":"20","4":"20","5":"1"},{"1":"Monte Carlo","2":"5","3":"21","4":"21","5":"2"},{"1":"Monte Carlo","2":"5","3":"22","4":"22","5":"3"},{"1":"Monte Carlo","2":"5","3":"23","4":"23","5":"4"},{"1":"Monte Carlo","2":"5","3":"24","4":"24","5":"5"},{"1":"Barcelona","2":"5","3":"25","4":"25","5":"6"},{"1":"Barcelona","2":"5","3":"27","4":"27","5":"8"},{"1":"Barcelona","2":"5","3":"27","4":"27","5":"8"},{"1":"Barcelona","2":"5","3":"28","4":"28","5":"9"},{"1":"Barcelona","2":"5","3":"29","4":"29","5":"10"},{"1":"Madrid","2":"5","3":"30","4":"29","5":"11"},{"1":"Madrid","2":"5","3":"31","4":"29","5":"12"},{"1":"Madrid","2":"5","3":"32","4":"30","5":"13"},{"1":"Madrid","2":"5","3":"33","4":"29","5":"14"},{"1":"Madrid","2":"5","3":"34","4":"30","5":"15"},{"1":"Rome","2":"5","3":"35","4":"30","5":"16"},{"1":"Rome","2":"5","3":"36","4":"30","5":"17"},{"1":"Rome","2":"5","3":"37","4":"30","5":"17"},{"1":"Rome","2":"5","3":"38","4":"30","5":"17"},{"1":"Rome","2":"5","3":"39","4":"31","5":"17"},{"1":"Paris","2":"4","3":"40","4":"32","5":"12"},{"1":"Paris","2":"4","3":"41","4":"29","5":"12"},{"1":"Paris","2":"4","3":"42","4":"29","5":"13"},{"1":"Paris","2":"4","3":"43","4":"30","5":"14"},{"1":"Paris","2":"4","3":"44","4":"31","5":"15"},{"1":"Paris","2":"4","3":"45","4":"32","5":"15"},{"1":"Paris","2":"4","3":"46","4":"31","5":"14"},{"1":"London","2":"5","3":"47","4":"28","5":"8"},{"1":"Montreal","2":"4","3":"46","4":"17","5":"1"},{"1":"Montreal","2":"4","3":"47","4":"17","5":"2"},{"1":"Montreal","2":"4","3":"46","4":"16","5":"3"},{"1":"Montreal","2":"4","3":"48","4":"18","5":"5"},{"1":"Montreal","2":"4","3":"48","4":"18","5":"5"},{"1":"Cincinnati","2":"3","3":"46","4":"16","5":"6"},{"1":"Cincinnati","2":"3","3":"46","4":"16","5":"7"},{"1":"Cincinnati","2":"3","3":"48","4":"17","5":"9"},{"1":"Cincinnati","2":"3","3":"48","4":"17","5":"9"},{"1":"Cincinnati","2":"3","3":"49","4":"18","5":"10"},{"1":"New York","2":"2","3":"49","4":"18","5":"11"},{"1":"New York","2":"2","3":"46","4":"17","5":"12"},{"1":"New York","2":"2","3":"47","4":"18","5":"13"},{"1":"New York","2":"2","3":"48","4":"17","5":"14"},{"1":"New York","2":"2","3":"49","4":"17","5":"15"},{"1":"New York","2":"2","3":"48","4":"17","5":"14"},{"1":"New York","2":"2","3":"49","4":"18","5":"14"},{"1":"Beijing","2":"2","3":"29","4":"1","5":"1"},{"1":"Beijing","2":"2","3":"30","4":"2","5":"2"},{"1":"Beijing","2":"2","3":"31","4":"3","5":"3"},{"1":"Beijing","2":"2","3":"32","4":"4","5":"4"},{"1":"Beijing","2":"2","3":"33","4":"5","5":"5"},{"1":"Shanghai","2":"1","3":"46","4":"18","5":"1"},{"1":"Shanghai","2":"1","3":"47","4":"19","5":"2"},{"1":"Shanghai","2":"1","3":"48","4":"20","5":"3"},{"1":"Shanghai","2":"1","3":"49","4":"21","5":"4"},{"1":"Paris","2":"1","3":"40","4":"22","5":"5"},{"1":"Paris","2":"1","3":"41","4":"23","5":"6"},{"1":"Paris","2":"1","3":"42","4":"24","5":"7"},{"1":"Paris","2":"1","3":"43","4":"25","5":"8"},{"1":"London","2":"1","3":"42","4":"25","5":"9"},{"1":"London","2":"1","3":"42","4":"25","5":"10"},{"1":"London","2":"1","3":"41","4":"25","5":"10"},{"1":"London","2":"1","3":"42","4":"24","5":"9"},{"1":"London","2":"1","3":"42","4":"25","5":"9"},{"1":"Doha","2":"1","3":"31","4":"14","5":"1"},{"1":"Doha","2":"1","3":"32","4":"15","5":"2"},{"1":"Doha","2":"1","3":"33","4":"16","5":"3"},{"1":"Doha","2":"1","3":"34","4":"17","5":"4"},{"1":"Doha","2":"1","3":"35","4":"18","5":"5"},{"1":"Melbourne","2":"1","3":"36","4":"15","5":"6"},{"1":"Melbourne","2":"1","3":"37","4":"16","5":"7"},{"1":"Melbourne","2":"1","3":"38","4":"17","5":"8"},{"1":"Melbourne","2":"1","3":"39","4":"18","5":"9"},{"1":"Melbourne","2":"1","3":"40","4":"19","5":"10"},{"1":"Melbourne","2":"1","3":"41","4":"20","5":"11"},{"1":"Melbourne","2":"1","3":"42","4":"21","5":"12"},{"1":"Rio de Janeiro","2":"1","3":"33","4":"13","5":"5"},{"1":"Rio de Janeiro","2":"1","3":"34","4":"14","5":"5"},{"1":"Rio de Janeiro","2":"1","3":"35","4":"16","5":"6"},{"1":"Rio de Janeiro","2":"1","3":"35","4":"16","5":"6"},{"1":"Rio de Janeiro","2":"1","3":"36","4":"17","5":"6"},{"1":"Indian Wells","2":"1","3":"31","4":"18","5":"6"},{"1":"Indian Wells","2":"1","3":"32","4":"19","5":"7"},{"1":"Miami","2":"1","3":"33","4":"20","5":"6"},{"1":"Miami","2":"1","3":"34","4":"21","5":"5"},{"1":"Miami","2":"1","3":"35","4":"22","5":"5"},{"1":"Miami","2":"1","3":"36","4":"23","5":"6"},{"1":"Miami","2":"1","3":"37","4":"24","5":"7"},{"1":"Miami","2":"1","3":"38","4":"25","5":"8"},{"1":"Monte Carlo","2":"1","3":"35","4":"19","5":"7"},{"1":"Monte Carlo","2":"1","3":"36","4":"20","5":"8"},{"1":"Monte Carlo","2":"1","3":"37","4":"20","5":"9"},{"1":"Barcelona","2":"1","3":"38","4":"19","5":"8"},{"1":"Barcelona","2":"1","3":"39","4":"19","5":"9"},{"1":"Barcelona","2":"1","3":"40","4":"20","5":"9"},{"1":"Madrid","2":"1","3":"34","4":"20","5":"7"},{"1":"Madrid","2":"1","3":"35","4":"21","5":"8"},{"1":"Madrid","2":"1","3":"35","4":"22","5":"9"},{"1":"Madrid","2":"1","3":"35","4":"23","5":"10"},{"1":"Madrid","2":"1","3":"36","4":"24","5":"11"},{"1":"Rome","2":"1","3":"37","4":"25","5":"12"},{"1":"Rome","2":"1","3":"38","4":"26","5":"13"},{"1":"Rome","2":"1","3":"39","4":"27","5":"13"},{"1":"Rome","2":"1","3":"40","4":"28","5":"13"},{"1":"Rome","2":"1","3":"41","4":"29","5":"13"},{"1":"Paris","2":"1","3":"42","4":"25","5":"11"},{"1":"Paris","2":"1","3":"43","4":"26","5":"12"},{"1":"Paris","2":"1","3":"44","4":"27","5":"13"},{"1":"Paris","2":"1","3":"45","4":"28","5":"14"},{"1":"Paris","2":"1","3":"46","4":"29","5":"15"},{"1":"Paris","2":"1","3":"47","4":"30","5":"15"},{"1":"Paris","2":"1","3":"48","4":"30","5":"14"},{"1":"Halle","2":"1","3":"49","4":"30","5":"13"},{"1":"London","2":"1","3":"50","4":"28","5":"9"},{"1":"London","2":"1","3":"51","4":"27","5":"9"},{"1":"London","2":"1","3":"52","4":"27","5":"9"},{"1":"London","2":"1","3":"50","4":"28","5":"9"},{"1":"Beijing","2":"2","3":"29","4":"1","5":"1"},{"1":"Beijing","2":"2","3":"30","4":"2","5":"2"},{"1":"Beijing","2":"2","3":"31","4":"3","5":"3"},{"1":"Shanghai","2":"2","3":"32","4":"4","5":"4"},{"1":"Basel","2":"3","3":"29","4":"5","5":"5"},{"1":"Basel","2":"3","3":"28","4":"6","5":"6"},{"1":"Basel","2":"3","3":"29","4":"7","5":"7"},{"1":"Doha","2":"3","3":"8","4":"4","5":"1"},{"1":"Melbourne","2":"3","3":"9","4":"4","5":"2"},{"1":"Melbourne","2":"3","3":"10","4":"4","5":"3"},{"1":"Melbourne","2":"3","3":"11","4":"4","5":"4"},{"1":"Melbourne","2":"3","3":"12","4":"5","5":"5"},{"1":"Melbourne","2":"3","3":"13","4":"6","5":"6"},{"1":"Rio de Janeiro","2":"3","3":"14","4":"7","5":"6"},{"1":"Rio de Janeiro","2":"3","3":"15","4":"8","5":"6"},{"1":"Rio de Janeiro","2":"3","3":"17","4":"10","5":"7"},{"1":"Rio de Janeiro","2":"3","3":"17","4":"10","5":"7"},{"1":"Buenos Aires","2":"4","3":"18","4":"11","5":"5"},{"1":"Buenos Aires","2":"4","3":"20","4":"13","5":"7"},{"1":"Buenos Aires","2":"4","3":"20","4":"13","5":"7"},{"1":"Buenos Aires","2":"4","3":"21","4":"14","5":"8"},{"1":"Indian Wells","2":"3","3":"22","4":"15","5":"9"},{"1":"Indian Wells","2":"3","3":"23","4":"16","5":"10"},{"1":"Indian Wells","2":"3","3":"24","4":"17","5":"11"},{"1":"Indian Wells","2":"3","3":"25","4":"18","5":"11"},{"1":"Miami","2":"3","3":"26","4":"19","5":"9"},{"1":"Miami","2":"3","3":"26","4":"20","5":"9"},{"1":"Monte Carlo","2":"5","3":"24","4":"20","5":"6"},{"1":"Monte Carlo","2":"5","3":"25","4":"21","5":"6"},{"1":"Monte Carlo","2":"5","3":"26","4":"22","5":"6"},{"1":"Monte Carlo","2":"5","3":"26","4":"23","5":"7"},{"1":"Barcelona","2":"4","3":"25","4":"22","5":"7"},{"1":"Barcelona","2":"4","3":"26","4":"22","5":"8"},{"1":"Madrid","2":"4","3":"27","4":"21","5":"7"},{"1":"Madrid","2":"4","3":"28","4":"22","5":"8"},{"1":"Madrid","2":"4","3":"29","4":"23","5":"9"},{"1":"Madrid","2":"4","3":"30","4":"24","5":"10"},{"1":"Madrid","2":"4","3":"31","4":"25","5":"11"},{"1":"Rome","2":"7","3":"32","4":"26","5":"12"},{"1":"Rome","2":"7","3":"33","4":"27","5":"13"},{"1":"Rome","2":"7","3":"34","4":"28","5":"13"},{"1":"Paris","2":"7","3":"35","4":"25","5":"9"},{"1":"Paris","2":"7","3":"36","4":"25","5":"10"},{"1":"Paris","2":"7","3":"37","4":"23","5":"11"},{"1":"Paris","2":"7","3":"38","4":"24","5":"12"},{"1":"Paris","2":"7","3":"39","4":"25","5":"13"},{"1":"Stuttgart","2":"10","3":"40","4":"26","5":"9"},{"1":"Stuttgart","2":"10","3":"41","4":"27","5":"9"},{"1":"Stuttgart","2":"10","3":"42","4":"28","5":"9"},{"1":"Stuttgart","2":"10","3":"43","4":"28","5":"9"},{"1":"Queens Club","2":"10","3":"44","4":"27","5":"10"},{"1":"London","2":"10","3":"45","4":"25","5":"8"},{"1":"London","2":"10","3":"46","4":"26","5":"8"},{"1":"Hamburg","2":"10","3":"41","4":"21","5":"3"},{"1":"Hamburg","2":"10","3":"42","4":"22","5":"3"},{"1":"Hamburg","2":"10","3":"43","4":"23","5":"4"},{"1":"Hamburg","2":"10","3":"44","4":"24","5":"4"},{"1":"Hamburg","2":"10","3":"45","4":"25","5":"5"},{"1":"Montreal","2":"9","3":"46","4":"19","5":"6"},{"1":"Montreal","2":"9","3":"47","4":"19","5":"7"},{"1":"Montreal","2":"9","3":"48","4":"20","5":"8"},{"1":"Cincinnati","2":"8","3":"45","4":"21","5":"9"},{"1":"Cincinnati","2":"8","3":"46","4":"22","5":"10"},{"1":"New York","2":"8","3":"43","4":"18","5":"6"},{"1":"New York","2":"8","3":"44","4":"19","5":"7"},{"1":"New York","2":"8","3":"45","4":"20","5":"8"},{"1":"Beijing","2":"8","3":"40","4":"14","5":"1"},{"1":"Beijing","2":"8","3":"41","4":"15","5":"2"},{"1":"Beijing","2":"8","3":"42","4":"16","5":"3"},{"1":"Beijing","2":"8","3":"43","4":"17","5":"4"},{"1":"Beijing","2":"8","3":"44","4":"18","5":"5"},{"1":"Shanghai","2":"7","3":"42","4":"19","5":"6"},{"1":"Shanghai","2":"7","3":"42","4":"20","5":"7"},{"1":"Shanghai","2":"7","3":"43","4":"21","5":"8"},{"1":"Shanghai","2":"7","3":"44","4":"22","5":"9"},{"1":"Basel","2":"7","3":"43","4":"22","5":"10"},{"1":"Basel","2":"7","3":"44","4":"22","5":"11"},{"1":"Basel","2":"7","3":"45","4":"21","5":"12"},{"1":"Basel","2":"7","3":"46","4":"21","5":"13"},{"1":"Basel","2":"7","3":"47","4":"22","5":"14"},{"1":"Paris","2":"6","3":"45","4":"23","5":"15"},{"1":"Paris","2":"6","3":"45","4":"24","5":"15"},{"1":"Paris","2":"6","3":"45","4":"25","5":"15"},{"1":"London","2":"5","3":"43","4":"23","5":"9"},{"1":"London","2":"5","3":"44","4":"23","5":"10"},{"1":"London","2":"5","3":"45","4":"23","5":"11"},{"1":"London","2":"5","3":"46","4":"24","5":"12"},{"1":"Doha","2":"5","3":"35","4":"20","5":"1"},{"1":"Doha","2":"5","3":"36","4":"21","5":"2"},{"1":"Doha","2":"5","3":"37","4":"21","5":"3"},{"1":"Doha","2":"5","3":"38","4":"21","5":"4"},{"1":"Doha","2":"5","3":"39","4":"21","5":"5"},{"1":"Melbourne","2":"5","3":"40","4":"18","5":"6"},{"1":"Buenos Aires","2":"5","3":"34","4":"12","5":"3"},{"1":"Buenos Aires","2":"5","3":"34","4":"12","5":"3"},{"1":"Buenos Aires","2":"5","3":"35","4":"13","5":"4"},{"1":"Rio de Janeiro","2":"5","3":"35","4":"12","5":"5"},{"1":"Rio de Janeiro","2":"5","3":"35","4":"12","5":"5"},{"1":"Rio de Janeiro","2":"5","3":"36","4":"12","5":"6"},{"1":"Rio de Janeiro","2":"5","3":"37","4":"13","5":"7"},{"1":"Indian Wells","2":"5","3":"35","4":"14","5":"5"},{"1":"Indian Wells","2":"5","3":"36","4":"15","5":"6"},{"1":"Indian Wells","2":"5","3":"37","4":"16","5":"7"},{"1":"Indian Wells","2":"5","3":"38","4":"17","5":"7"},{"1":"Indian Wells","2":"5","3":"39","4":"18","5":"7"},{"1":"Miami","2":"5","3":"40","4":"19","5":"6"},{"1":"Monte Carlo","2":"5","3":"33","4":"15","5":"6"},{"1":"Monte Carlo","2":"5","3":"33","4":"16","5":"6"},{"1":"Monte Carlo","2":"5","3":"34","4":"17","5":"6"},{"1":"Monte Carlo","2":"5","3":"35","4":"18","5":"7"},{"1":"Monte Carlo","2":"5","3":"36","4":"19","5":"7"},{"1":"Barcelona","2":"5","3":"37","4":"19","5":"7"},{"1":"Barcelona","2":"5","3":"38","4":"20","5":"8"},{"1":"Barcelona","2":"5","3":"39","4":"21","5":"9"},{"1":"Barcelona","2":"5","3":"39","4":"22","5":"10"},{"1":"Barcelona","2":"5","3":"40","4":"23","5":"11"},{"1":"Madrid","2":"5","3":"35","4":"24","5":"11"},{"1":"Madrid","2":"5","3":"35","4":"25","5":"12"},{"1":"Madrid","2":"5","3":"36","4":"26","5":"13"},{"1":"Madrid","2":"5","3":"37","4":"27","5":"14"},{"1":"Rome","2":"5","3":"38","4":"28","5":"15"},{"1":"Rome","2":"5","3":"39","4":"27","5":"16"},{"1":"Rome","2":"5","3":"40","4":"27","5":"16"},{"1":"Paris","2":"5","3":"37","4":"24","5":"8"},{"1":"Paris","2":"5","3":"38","4":"25","5":"9"},{"1":"Paris","2":"5","3":"39","4":"26","5":"10"},{"1":"Cincinnati","2":"5","3":"28","4":"4","5":"1"},{"1":"Cincinnati","2":"5","3":"29","4":"5","5":"2"},{"1":"New York","2":"5","3":"29","4":"3","5":"3"},{"1":"New York","2":"5","3":"30","4":"4","5":"4"},{"1":"New York","2":"5","3":"31","4":"5","5":"5"},{"1":"New York","2":"5","3":"32","4":"6","5":"6"},{"1":"Beijing","2":"4","3":"27","4":"7","5":"1"},{"1":"Beijing","2":"4","3":"28","4":"8","5":"2"},{"1":"Beijing","2":"4","3":"29","4":"9","5":"3"},{"1":"Shanghai","2":"5","3":"27","4":"10","5":"4"},{"1":"Brisbane","2":"9","3":"12","4":"5","5":"2"},{"1":"Brisbane","2":"9","3":"13","4":"4","5":"3"},{"1":"Brisbane","2":"9","3":"14","4":"5","5":"4"},{"1":"Melbourne","2":"9","3":"15","4":"5","5":"5"},{"1":"Melbourne","2":"9","3":"16","4":"6","5":"6"},{"1":"Melbourne","2":"9","3":"17","4":"7","5":"7"},{"1":"Melbourne","2":"9","3":"18","4":"8","5":"8"},{"1":"Melbourne","2":"9","3":"19","4":"9","5":"9"},{"1":"Melbourne","2":"9","3":"20","4":"10","5":"10"},{"1":"Melbourne","2":"9","3":"21","4":"11","5":"11"},{"1":"Acapulco","2":"6","3":"18","4":"12","5":"1"},{"1":"Acapulco","2":"6","3":"19","4":"14","5":"3"},{"1":"Acapulco","2":"6","3":"19","4":"14","5":"3"},{"1":"Acapulco","2":"6","3":"19","4":"15","5":"4"},{"1":"Acapulco","2":"6","3":"20","4":"16","5":"5"},{"1":"Indian Wells","2":"6","3":"21","4":"17","5":"6"},{"1":"Indian Wells","2":"6","3":"22","4":"18","5":"7"},{"1":"Indian Wells","2":"6","3":"23","4":"19","5":"8"},{"1":"Miami","2":"7","3":"24","4":"20","5":"9"},{"1":"Miami","2":"7","3":"25","4":"21","5":"10"},{"1":"Miami","2":"7","3":"26","4":"22","5":"11"},{"1":"Miami","2":"7","3":"27","4":"23","5":"12"},{"1":"Miami","2":"7","3":"28","4":"24","5":"12"},{"1":"Miami","2":"7","3":"11","4":"4","5":"1"},{"1":"Monte Carlo","2":"7","3":"25","4":"19","5":"6"},{"1":"Monte Carlo","2":"7","3":"26","4":"20","5":"7"},{"1":"Monte Carlo","2":"7","3":"27","4":"20","5":"8"},{"1":"Monte Carlo","2":"7","3":"28","4":"21","5":"9"},{"1":"Monte Carlo","2":"7","3":"29","4":"21","5":"9"},{"1":"Barcelona","2":"5","3":"30","4":"21","5":"9"},{"1":"Barcelona","2":"5","3":"31","4":"21","5":"9"},{"1":"Barcelona","2":"5","3":"32","4":"22","5":"10"},{"1":"Barcelona","2":"5","3":"33","4":"22","5":"10"},{"1":"Barcelona","2":"5","3":"34","4":"23","5":"10"},{"1":"Madrid","2":"5","3":"35","4":"24","5":"11"},{"1":"Madrid","2":"5","3":"36","4":"25","5":"12"},{"1":"Madrid","2":"5","3":"37","4":"26","5":"13"},{"1":"Madrid","2":"5","3":"38","4":"27","5":"14"},{"1":"Madrid","2":"5","3":"39","4":"28","5":"15"},{"1":"Rome","2":"4","3":"40","4":"29","5":"16"},{"1":"Rome","2":"4","3":"41","4":"30","5":"17"},{"1":"Rome","2":"4","3":"42","4":"31","5":"17"},{"1":"Paris","2":"4","3":"43","4":"32","5":"10"},{"1":"Paris","2":"4","3":"44","4":"30","5":"10"},{"1":"Paris","2":"4","3":"45","4":"30","5":"11"},{"1":"Paris","2":"4","3":"46","4":"30","5":"12"},{"1":"Paris","2":"4","3":"47","4":"31","5":"13"},{"1":"Paris","2":"4","3":"48","4":"32","5":"13"},{"1":"Paris","2":"4","3":"49","4":"32","5":"12"},{"1":"London","2":"2","3":"48","4":"26","5":"5"},{"1":"London","2":"2","3":"47","4":"27","5":"5"},{"1":"London","2":"2","3":"48","4":"28","5":"5"},{"1":"London","2":"2","3":"49","4":"29","5":"5"},{"1":"Montreal","2":"2","3":"43","4":"18","5":"1"},{"1":"Montreal","2":"2","3":"44","4":"17","5":"2"},{"1":"Cincinnati","2":"2","3":"45","4":"14","5":"3"},{"1":"Cincinnati","2":"2","3":"46","4":"15","5":"4"},{"1":"Cincinnati","2":"2","3":"47","4":"16","5":"5"},{"1":"New York","2":"1","3":"45","4":"15","5":"6"},{"1":"New York","2":"1","3":"44","4":"15","5":"7"},{"1":"New York","2":"1","3":"45","4":"15","5":"8"},{"1":"New York","2":"1","3":"46","4":"16","5":"9"},{"1":"New York","2":"1","3":"47","4":"16","5":"10"},{"1":"New York","2":"1","3":"47","4":"15","5":"10"},{"1":"New York","2":"1","3":"47","4":"16","5":"10"},{"1":"Beijing","2":"1","3":"42","4":"15","5":"5"},{"1":"Beijing","2":"1","3":"43","4":"15","5":"5"},{"1":"Beijing","2":"1","3":"44","4":"16","5":"5"},{"1":"Beijing","2":"1","3":"45","4":"17","5":"6"},{"1":"Beijing","2":"1","3":"46","4":"17","5":"7"},{"1":"Shanghai","2":"1","3":"47","4":"18","5":"6"},{"1":"Shanghai","2":"1","3":"48","4":"19","5":"7"},{"1":"Shanghai","2":"1","3":"49","4":"20","5":"8"},{"1":"Shanghai","2":"1","3":"50","4":"21","5":"9"},{"1":"Shanghai","2":"1","3":"51","4":"22","5":"10"},{"1":"Paris","2":"1","3":"42","4":"23","5":"11"},{"1":"Paris","2":"1","3":"43","4":"24","5":"11"},{"1":"Paris","2":"1","3":"44","4":"25","5":"12"},{"1":"London","2":"1","3":"39","4":"24","5":"5"},{"1":"Melbourne","2":"1","3":"27","4":"5","5":"1"},{"1":"Melbourne","2":"1","3":"28","4":"6","5":"2"},{"1":"Melbourne","2":"1","3":"29","4":"7","5":"3"},{"1":"Melbourne","2":"1","3":"30","4":"8","5":"4"},{"1":"Melbourne","2":"1","3":"31","4":"9","5":"5"},{"1":"Monte Carlo","2":"1","3":"10","4":"4","5":"1"},{"1":"Monte Carlo","2":"1","3":"11","4":"4","5":"2"},{"1":"Monte Carlo","2":"1","3":"12","4":"5","5":"3"},{"1":"Monte Carlo","2":"1","3":"13","4":"5","5":"4"},{"1":"Monte Carlo","2":"1","3":"14","4":"6","5":"5"},{"1":"Barcelona","2":"1","3":"15","4":"6","5":"6"},{"1":"Barcelona","2":"1","3":"16","4":"7","5":"7"},{"1":"Barcelona","2":"1","3":"17","4":"8","5":"8"},{"1":"Barcelona","2":"1","3":"18","4":"9","5":"9"},{"1":"Barcelona","2":"1","3":"19","4":"10","5":"10"},{"1":"Madrid","2":"1","3":"17","4":"11","5":"11"},{"1":"Madrid","2":"1","3":"18","4":"12","5":"12"},{"1":"Madrid","2":"1","3":"19","4":"13","5":"13"},{"1":"Rome","2":"2","3":"19","4":"14","5":"14"},{"1":"Rome","2":"2","3":"20","4":"15","5":"15"},{"1":"Rome","2":"2","3":"21","4":"16","5":"15"},{"1":"Rome","2":"2","3":"22","4":"17","5":"15"},{"1":"Rome","2":"2","3":"23","4":"18","5":"15"},{"1":"Paris","2":"1","3":"24","4":"19","5":"9"},{"1":"Paris","2":"1","3":"25","4":"20","5":"10"},{"1":"Paris","2":"1","3":"26","4":"21","5":"11"},{"1":"Paris","2":"1","3":"27","4":"22","5":"12"},{"1":"Paris","2":"1","3":"28","4":"23","5":"13"},{"1":"Paris","2":"1","3":"29","4":"24","5":"13"},{"1":"Paris","2":"1","3":"30","4":"25","5":"12"},{"1":"London","2":"1","3":"31","4":"26","5":"5"},{"1":"London","2":"1","3":"32","4":"27","5":"5"},{"1":"London","2":"1","3":"33","4":"28","5":"5"},{"1":"London","2":"1","3":"34","4":"29","5":"5"},{"1":"London","2":"1","3":"35","4":"30","5":"5"},{"1":"London","2":"1","3":"35","4":"31","5":"6"}],"options":{"columns":{"min":{},"max":[10],"total":[5]},"rows":{"min":[10],"max":[10],"total":[1123]},"pages":{}}}
  </script>
</div>

<!-- rnb-frame-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuXG4jRWxpbWlubyBwcmltZXJhcyA1MCBvYnNlcnZhY2lvbmVzLCBhIHBhcnRpciBkZSBhaGkgc2Ugbml2ZWxhXG5cbmRmX21hdGNoZXMgPC0gZGZfbWF0Y2hlc1s1MTpucm93KGRmX21hdGNoZXMpLF1cblxuYGBgIn0= -->

```r

#Elimino primeras 50 observaciones, a partir de ahi se nivela

df_matches <- df_matches[51:nrow(df_matches),]

```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->



##Plots

A continuacion se presentan algunos graficos interesantes que nos ayudaran a comprender el comportamiento de algunas variables.


<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuXG5kZl9tYXRjaGVzICU+JSBcbiAgZ2dwbG90KGFlcyh4ID0gUGFydGlkb3NVbHQ2TWVzZXMsIHkgPSBXUlVsdDZNZXNlcyxcbiAgICAgICAgICAgICBjb2xvciA9IFJlc3VsdCkpICsgXG4gIGdlb21faml0dGVyKHdpZHRoID0gMS41KSAjQ3VhbmRvIGp1Z8OzIG11Y2hvcyBwYXJ0aWRvcyB5IGNvbiBhbHRvIHdyIGhheSBtYXMgY2hhbmNlIGRlIGdhbmFyXG5gYGAifQ== -->

```r

df_matches %>% 
  ggplot(aes(x = PartidosUlt6Meses, y = WRUlt6Meses,
             color = Result)) + 
  geom_jitter(width = 1.5) #Cuando jugó muchos partidos y con alto wr hay mas chance de ganar
```

<!-- rnb-source-end -->

<!-- rnb-plot-begin eyJoZWlnaHQiOjQzMi42MzI5LCJ3aWR0aCI6NzAwLCJzaXplX2JlaGF2aW9yIjowLCJjb25kaXRpb25zIjpbXX0= -->

<img src="data:image/png;base64,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" />

<!-- rnb-plot-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuXG5kZl9tYXRjaGVzICU+JSBcbiAgZ2dwbG90KGFlcyh4ID0gUmFua05hZGFsLCB5ID0gUmFua1JpdmFsLFxuICAgICAgICAgICAgIGNvbG9yID0gUmVzdWx0KSkgKyBcbiAgZ2VvbV9qaXR0ZXIoKSArIFxuICBjb29yZF9jYXJ0ZXNpYW4oeWxpbSA9IGMoMCwgMjApLFxuICAgICAgICAgICAgICAgICAgeGxpbSA9IGMoMCwgMTApKVxuYGBgIn0= -->

```r

df_matches %>% 
  ggplot(aes(x = RankNadal, y = RankRival,
             color = Result)) + 
  geom_jitter() + 
  coord_cartesian(ylim = c(0, 20),
                  xlim = c(0, 10))
```

<!-- rnb-source-end -->

<!-- rnb-plot-begin eyJoZWlnaHQiOjQzMi42MzI5LCJ3aWR0aCI6NzAwLCJzaXplX2JlaGF2aW9yIjowLCJjb25kaXRpb25zIjpbXX0= -->

<img src="data:image/png;base64,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" />

<!-- rnb-plot-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuXG5kZl9tYXRjaGVzICU+JSBcbiAgZ2dwbG90KGFlcyh4ID0gU3VyZmFjZSwgZmlsbCA9IFJlc3VsdCkpICsgXG4gIGdlb21fYmFyKHBvc2l0aW9uID0gXCJmaWxsXCIpXG5gYGAifQ== -->

```r

df_matches %>% 
  ggplot(aes(x = Surface, fill = Result)) + 
  geom_bar(position = "fill")
```

<!-- rnb-source-end -->

<!-- rnb-plot-begin eyJoZWlnaHQiOjQzMi42MzI5LCJ3aWR0aCI6NzAwLCJzaXplX2JlaGF2aW9yIjowLCJjb25kaXRpb25zIjpbXX0= -->

<img src="data:image/png;base64,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" />

<!-- rnb-plot-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuXG5kZl9tYXRjaGVzICU+JSBcbiAgZ2dwbG90KGFlcyh4ID0gQmVzdE9mLCBmaWxsID0gUmVzdWx0KSkgKyBcbiAgZ2VvbV9iYXIocG9zaXRpb24gPSBcImZpbGxcIikgKyBcbiAgZmFjZXRfZ3JpZCguflN1cmZhY2UpXG5gYGAifQ== -->

```r

df_matches %>% 
  ggplot(aes(x = BestOf, fill = Result)) + 
  geom_bar(position = "fill") + 
  facet_grid(.~Surface)
```

<!-- rnb-source-end -->

<!-- rnb-plot-begin eyJoZWlnaHQiOjQzMi42MzI5LCJ3aWR0aCI6NzAwLCJzaXplX2JlaGF2aW9yIjowLCJjb25kaXRpb25zIjpbXX0= -->

<img src="data:image/png;base64,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" />

<!-- rnb-plot-end -->

<!-- rnb-plot-begin -->

<img src="data:image/png;base64," />

<!-- rnb-plot-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuXG5kZl9tYXRjaGVzICU+JSBcbiAgZ2dwbG90KGFlcyh4ID0gUm91bmQsIGZpbGwgPSBSZXN1bHQpKSArIFxuICBnZW9tX2Jhcihwb3NpdGlvbiA9IFwiZmlsbFwiKSArIFxuICBmYWNldF9ncmlkKC5+U3VyZmFjZSkgKyBcbiAgdGhlbWUoYXhpcy50ZXh0LnggPSBlbGVtZW50X3RleHQoYW5nbGUgPSA0NSkpXG5gYGAifQ== -->

```r

df_matches %>% 
  ggplot(aes(x = Round, fill = Result)) + 
  geom_bar(position = "fill") + 
  facet_grid(.~Surface) + 
  theme(axis.text.x = element_text(angle = 45))
```

<!-- rnb-source-end -->

<!-- rnb-plot-begin eyJoZWlnaHQiOjQzMi42MzI5LCJ3aWR0aCI6NzAwLCJzaXplX2JlaGF2aW9yIjowLCJjb25kaXRpb25zIjpbXX0= -->

<img src="data:image/png;base64,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" />

<!-- rnb-plot-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuXG5nbGltcHNlKGRmX21hdGNoZXMpXG5gYGAifQ== -->

```r

glimpse(df_matches)
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiUm93czogMSwwNzNcbkNvbHVtbnM6IDI4XG4kIExvY2F0aW9uICAgICAgICAgICAgICAgPGZjdD4gUGFyaXMsIFBhcmlzLCBQYXJpcywgUGFyaXMsIEhhbGxlLCBMb25kb24sIExvbmRvbiwgQmFzdGFkLCBCYXN0YWQsIEJhc3RhZCwgQn5cbiQgU2VyaWVzICAgICAgICAgICAgICAgICA8ZmN0PiBHcmFuZCBTbGFtLCBHcmFuZCBTbGFtLCBHcmFuZCBTbGFtLCBHcmFuZCBTbGFtLCBJbnRlcm5hdGlvbmFsLCBHcmFuZCBTbGFtLCBHflxuJCBDb3VydCAgICAgICAgICAgICAgICAgIDxmY3Q+IE91dGRvb3IsIE91dGRvb3IsIE91dGRvb3IsIE91dGRvb3IsIE91dGRvb3IsIE91dGRvb3IsIE91dGRvb3IsIE91dGRvb3IsIE91dGR+XG4kIFN1cmZhY2UgICAgICAgICAgICAgICAgPGZjdD4gQ2xheSwgQ2xheSwgQ2xheSwgQ2xheSwgR3Jhc3MsIEdyYXNzLCBHcmFzcywgQ2xheSwgQ2xheSwgQ2xheSwgQ2xheSwgQ2xheSwgQ35cbiQgRGF0ZSAgICAgICAgICAgICAgICAgICA8ZGF0ZT4gMjAwNS0wNS0zMCwgMjAwNS0wNS0zMSwgMjAwNS0wNi0wMywgMjAwNS0wNi0wNSwgMjAwNS0wNi0wOCwgMjAwNS0wNi0yMSwgMjAwflxuJCBSb3VuZCAgICAgICAgICAgICAgICAgIDxmY3Q+IDR0aCBSb3VuZCwgUXVhcnRlcmZpbmFscywgU2VtaWZpbmFscywgVGhlIEZpbmFsLCAxc3QgUm91bmQsIDFzdCBSb3VuZCwgMm5kIFJ+XG4kIEJlc3RPZiAgICAgICAgICAgICAgICAgPGZjdD4gNSwgNSwgNSwgNSwgMywgNSwgNSwgMywgMywgMywgMywgMywgMywgMywgMywgMywgNSwgMywgMywgMywgMywgMywgMywgMywgNSwgNX5cbiQgUmFua05hZGFsICAgICAgICAgICAgICA8ZGJsPiA1LCA1LCA1LCA1LCAzLCAzLCAzLCAzLCAzLCAzLCAzLCAzLCAzLCAzLCAzLCAzLCAzLCAyLCAyLCAyLCAyLCAyLCAyLCAyLCAyLCAyflxuJCBSYW5rUml2YWwgICAgICAgICAgICAgIDxkYmw+IDI0LCAyMSwgMSwgMzcsIDE0NywgMzksIDY5LCA2NiwgNTAsIDMxLCAyMCwgNDIsIDE2NywgNTgsIDU3LCA2NiwgMTMsIDMyLCA1Nix+XG4kIFBhcnRpZG9zVWx0Nk1lc2VzICAgICAgPGludD4gNTEsIDUyLCA1MywgNTQsIDU1LCA1NiwgNTcsIDU1LCA1NiwgNTcsIDU4LCA1OCwgNTcsIDU3LCA1OCwgNTgsIDU5LCA1OCwgNTksIH5cbiQgUGFydGlkb3NVbHQzTWVzZXMgICAgICA8aW50PiAzMCwgMzEsIDMyLCAzMywgMzQsIDM1LCAzNSwgMzAsIDI5LCAzMCwgMzEsIDMxLCAyNSwgMjUsIDI1LCAyNSwgMjYsIDIxLCAyMywgflxuJCBQYXJ0aWRvc1VsdE1lcyAgICAgICAgIDxpbnQ+IDEwLCAxMSwgMTAsIDksIDgsIDksIDksIDQsIDUsIDUsIDYsIDcsIDgsIDgsIDksIDksIDEwLCA2LCA4LCA4LCA5LCAxMSwgMTEsIDF+XG4kIFdSVWx0Nk1lc2VzICAgICAgICAgICAgPGRibD4gMC44ODIzNTI5LCAwLjg4NDYxNTQsIDAuODg2NzkyNSwgMC44ODg4ODg5LCAwLjg3MjcyNzMsIDAuODc1MDAwMCwgMC44NTk2NDkxLH5cbiQgV1JVbHQzTWVzZXMgICAgICAgICAgICA8ZGJsPiAwLjkzMzMzMzMsIDAuOTM1NDgzOSwgMC45Mzc1MDAwLCAwLjkzOTM5MzksIDAuOTExNzY0NywgMC45MTQyODU3LCAwLjg4NTcxNDMsflxuJCBXUlVsdE1lcyAgICAgICAgICAgICAgIDxkYmw+IDEuMDAwMDAwMCwgMS4wMDAwMDAwLCAxLjAwMDAwMDAsIDEuMDAwMDAwMCwgMC44NzUwMDAwLCAwLjg4ODg4ODksIDAuNzc3Nzc3OCx+XG4kIFBhcnRpZG9zUml2YWxVbHQ2TWVzZXMgPGludD4gMjMsIDQzLCA0OSwgMzIsIDMsIDI0LCAyMywgMjgsIDM3LCA0NSwgMzUsIDMwLCA1LCAyOCwgMjcsIDIxLCA0OCwgMzEsIDIyLCAzMn5cbiQgUGFydGlkb3NSaXZhbFVsdDNNZXNlcyA8aW50PiAxNywgMzIsIDI4LCAyMCwgMywgNywgMTQsIDE2LCAxOCwgMjksIDIyLCAxOSwgNCwgMTQsIDE0LCAxMywgMjQsIDE0LCAxMCwgMTgsflxuJCBQYXJ0aWRvc1JpdmFsVWx0TWVzICAgIDxpbnQ+IDksIDExLCAxMiwgMTEsIDEsIDMsIDUsIDIsIDQsIDksIDcsIDEwLCAzLCA2LCA1LCA2LCAxMCwgOCwgNiwgNiwgMTAsIDgsIDExLCB+XG4kIFdSUml2YWxVbHQ2TWVzZXMgICAgICAgPGRibD4gMC42MDg2OTU3LCAwLjY1MTE2MjgsIDAuOTM4Nzc1NSwgMC43MTg3NTAwLCAwLjMzMzMzMzMsIDAuNTAwMDAwMCwgMC40MzQ3ODI2LH5cbiQgV1JSaXZhbFVsdDNNZXNlcyAgICAgICA8ZGJsPiAwLjY0NzA1ODgsIDAuNzUwMDAwMCwgMC45Mjg1NzE0LCAwLjc1MDAwMDAsIDAuMzMzMzMzMywgMC4yODU3MTQzLCAwLjUwMDAwMDAsflxuJCBXUlJpdmFsVWx0TWVzICAgICAgICAgIDxkYmw+IDAuNjY2NjY2NywgMC43MjcyNzI3LCAwLjkxNjY2NjcsIDAuNzI3MjcyNywgMS4wMDAwMDAwLCAwLjMzMzMzMzMsIDAuNjAwMDAwMCx+XG4kIFNldHNHYW5hZG9zVWx0UGFydGlkbyAgPGRibD4gMywgMywgMywgMywgMywgMSwgMywgMSwgMiwgMiwgMiwgMiwgMiwgMiwgMiwgMiwgMiwgMywgMiwgMiwgMiwgMiwgMiwgMiwgMSwgM35cbiQgU2V0c1BlcmRpZG9zVWx0UGFydGlkbyA8ZGJsPiAwLCAxLCAwLCAxLCAxLCAyLCAwLCAzLCAwLCAwLCAwLCAwLCAxLCAwLCAwLCAwLCAwLCAwLCAxLCAwLCAwLCAwLCAwLCAxLCAyLCAwflxuJCBSZXN1bHRVbHRQYXJ0aWRvICAgICAgIDxjaHI+IFwiV2luXCIsIFwiV2luXCIsIFwiV2luXCIsIFwiV2luXCIsIFwiV2luXCIsIFwiTG9zZVwiLCBcIldpblwiLCBcIkxvc2VcIiwgXCJXaW5cIiwgXCJXaW5cIiwgXCJXaW5+XG4kIFJvdW5kVWx0UGFydGlkbyAgICAgICAgPGNocj4gXCIzcmQgUm91bmRcIiwgXCI0dGggUm91bmRcIiwgXCJRdWFydGVyZmluYWxzXCIsIFwiU2VtaWZpbmFsc1wiLCBcIlRoZSBGaW5hbFwiLCBcIjFzdCBSflxuJCBIMkhQYXJ0aWRvcyAgICAgICAgICAgIDxpbnQ+IDAsIDIsIDEsIDEsIDAsIDAsIDEsIDAsIDEsIDIsIDAsIDAsIDAsIDIsIDAsIDAsIDIsIDAsIDEsIDEsIDIsIDAsIDAsIDEsIDEsIDB+XG4kIEgySEdhbmFkb3MgICAgICAgICAgICAgPGludD4gMCwgMiwgMCwgMSwgMCwgMCwgMSwgMCwgMSwgMiwgMCwgMCwgMCwgMiwgMCwgMCwgMSwgMCwgMSwgMSwgMiwgMCwgMCwgMSwgMSwgMH5cbiQgUmVzdWx0ICAgICAgICAgICAgICAgICA8ZmN0PiBXaW4sIFdpbiwgV2luLCBXaW4sIExvc2UsIFdpbiwgTG9zZSwgV2luLCBXaW4sIFdpbiwgV2luLCBXaW4sIFdpbiwgV2luLCBXaW4sflxuIn0= -->

```
Rows: 1,073
Columns: 28
$ Location               <fct> Paris, Paris, Paris, Paris, Halle, London, London, Bastad, Bastad, Bastad, B~
$ Series                 <fct> Grand Slam, Grand Slam, Grand Slam, Grand Slam, International, Grand Slam, G~
$ Court                  <fct> Outdoor, Outdoor, Outdoor, Outdoor, Outdoor, Outdoor, Outdoor, Outdoor, Outd~
$ Surface                <fct> Clay, Clay, Clay, Clay, Grass, Grass, Grass, Clay, Clay, Clay, Clay, Clay, C~
$ Date                   <date> 2005-05-30, 2005-05-31, 2005-06-03, 2005-06-05, 2005-06-08, 2005-06-21, 200~
$ Round                  <fct> 4th Round, Quarterfinals, Semifinals, The Final, 1st Round, 1st Round, 2nd R~
$ BestOf                 <fct> 5, 5, 5, 5, 3, 5, 5, 3, 3, 3, 3, 3, 3, 3, 3, 3, 5, 3, 3, 3, 3, 3, 3, 3, 5, 5~
$ RankNadal              <dbl> 5, 5, 5, 5, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 2, 2, 2, 2, 2, 2, 2, 2, 2~
$ RankRival              <dbl> 24, 21, 1, 37, 147, 39, 69, 66, 50, 31, 20, 42, 167, 58, 57, 66, 13, 32, 56,~
$ PartidosUlt6Meses      <int> 51, 52, 53, 54, 55, 56, 57, 55, 56, 57, 58, 58, 57, 57, 58, 58, 59, 58, 59, ~
$ PartidosUlt3Meses      <int> 30, 31, 32, 33, 34, 35, 35, 30, 29, 30, 31, 31, 25, 25, 25, 25, 26, 21, 23, ~
$ PartidosUltMes         <int> 10, 11, 10, 9, 8, 9, 9, 4, 5, 5, 6, 7, 8, 8, 9, 9, 10, 6, 8, 8, 9, 11, 11, 1~
$ WRUlt6Meses            <dbl> 0.8823529, 0.8846154, 0.8867925, 0.8888889, 0.8727273, 0.8750000, 0.8596491,~
$ WRUlt3Meses            <dbl> 0.9333333, 0.9354839, 0.9375000, 0.9393939, 0.9117647, 0.9142857, 0.8857143,~
$ WRUltMes               <dbl> 1.0000000, 1.0000000, 1.0000000, 1.0000000, 0.8750000, 0.8888889, 0.7777778,~
$ PartidosRivalUlt6Meses <int> 23, 43, 49, 32, 3, 24, 23, 28, 37, 45, 35, 30, 5, 28, 27, 21, 48, 31, 22, 32~
$ PartidosRivalUlt3Meses <int> 17, 32, 28, 20, 3, 7, 14, 16, 18, 29, 22, 19, 4, 14, 14, 13, 24, 14, 10, 18,~
$ PartidosRivalUltMes    <int> 9, 11, 12, 11, 1, 3, 5, 2, 4, 9, 7, 10, 3, 6, 5, 6, 10, 8, 6, 6, 10, 8, 11, ~
$ WRRivalUlt6Meses       <dbl> 0.6086957, 0.6511628, 0.9387755, 0.7187500, 0.3333333, 0.5000000, 0.4347826,~
$ WRRivalUlt3Meses       <dbl> 0.6470588, 0.7500000, 0.9285714, 0.7500000, 0.3333333, 0.2857143, 0.5000000,~
$ WRRivalUltMes          <dbl> 0.6666667, 0.7272727, 0.9166667, 0.7272727, 1.0000000, 0.3333333, 0.6000000,~
$ SetsGanadosUltPartido  <dbl> 3, 3, 3, 3, 3, 1, 3, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 2, 2, 2, 2, 2, 2, 1, 3~
$ SetsPerdidosUltPartido <dbl> 0, 1, 0, 1, 1, 2, 0, 3, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 2, 0~
$ ResultUltPartido       <chr> "Win", "Win", "Win", "Win", "Win", "Lose", "Win", "Lose", "Win", "Win", "Win~
$ RoundUltPartido        <chr> "3rd Round", "4th Round", "Quarterfinals", "Semifinals", "The Final", "1st R~
$ H2HPartidos            <int> 0, 2, 1, 1, 0, 0, 1, 0, 1, 2, 0, 0, 0, 2, 0, 0, 2, 0, 1, 1, 2, 0, 0, 1, 1, 0~
$ H2HGanados             <int> 0, 2, 0, 1, 0, 0, 1, 0, 1, 2, 0, 0, 0, 2, 0, 0, 1, 0, 1, 1, 2, 0, 0, 1, 1, 0~
$ Result                 <fct> Win, Win, Win, Win, Lose, Win, Lose, Win, Win, Win, Win, Win, Win, Win, Win,~
```



<!-- rnb-output-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->



##Model Train

Como primer paso, separo data post 2020 para usar en el testeo final de los modelos.
Ademas calculo las tasas de corte para las cuales el modelo supone una mejor estrategia a decir que siempre va a ganar Nadal.



<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuXG5kZl9tYXRjaGVzICU+JSBcbiAgZmlsdGVyKERhdGUgPj0gXCIyMDIwLTAxLTAxXCIpXG5gYGAifQ== -->

```r

df_matches %>% 
  filter(Date >= "2020-01-01")
```

<!-- rnb-source-end -->

<!-- rnb-frame-begin eyJtZXRhZGF0YSI6eyJjbGFzc2VzIjpbInRibF9kZiIsInRibCIsImRhdGEuZnJhbWUiXSwibnJvdyI6NDksIm5jb2wiOjI4LCJzdW1tYXJ5Ijp7IkEgdGliYmxlIjpbIjQ5IHggMjgiXX19LCJyZGYiOiJINHNJQUFBQUFBQUFCdDBhVzJ3YzFYV2M3SzY5NjBjY0VqQUJLeXlsMEllSTh5STgwNDdqTmNSSnZHRzltOFJBQmRYZDNldmR3Yk56dC9OSWF2Y25VZ3NTcW9SRWhWcjFBUzM5YUtWV2F0V2Z0cUlnb1VwVmZ5ZzBWS2c4STVLWTJFNkNGRUcvU2UrZE9lZk83SGpXdTdGTmhUcnk5ZGx6N25uZmU4K1ozWm44NkVPN1V3K2xGRVZacjhRNitQODQvNmdrTXJtZHUvYnNVcFRZT281MUtERWxLZUMzK2Z3bS9tR1F3MTRPZC9KeFY4UllGekVtQXVQZ1ZZenRvUkZsYjI5Z3BDTEc3c0NZV0RvYWdrem85RGpWTGY2cG53OGRxUDFmc3JhTlVkTm1GV29VbVZXcUFyMXJYNG5VSGIzRUpGNm1PdEhLRlBEVXZobzFyU25HVEJzb25mc01tK2d6SklDZW9HWmRvclpPT0lOVTU1U21PYUdNMHlQRXFFeXphVUNUSThRc1VaMFp5QjhmSVJaRm54TWNzWWt2U3JYSE5hT0Nta2VvWGpHSmREUXh3aXJNdHp0aWFsYVJHRlFhY2twVllsTExsZ3hPbWRSOXZHZkVvUWF6MHZzMHpvUThHVkxSTldKcW1Jc01zVWlSUjFPU3dXZXExS2lVblNCcUVKOWZNMG9hSjlpYVpHQTZxMGl2T0dxV1dSRzFiY2d3SG05NmxLVUx4TkhxeU5VelNuV1R6S1JIS0pITEZodGxWWm16VWFmbzJ4eDFMSjdCTWpPbmtISS96MktST2FadjluN0xacVltMDd5Zkd2UTRrUmozUVNZOVBrWjBYY3FOa1ZyUk1YRUZOb3l4ZEthcXBiT2FrYzVvOW96a1lnN1hiNkQzQjR5eVJvejBKTlYxcTVGRzZrelhaTElQY0x0RzBVR3ZlZzd5Q0EyRFdnR0x5VU9hUFZ0MHFuS0g5Qnh5aUU3UzQwNnQ3cGpJTkU2czlERmFJYWc1TWM2TXN2U25lMXlzc2xHaHVsem5wQ0JsQ0Q4V21OM3hHY21meUpLeXFXRSt1ckxFTFBKSU1GdEpqcHRrbXNxRkVRU0xhbjdTa2xtcU4yWS9TMnYxcW93N2xxWDJMR1k3cTVHYTVpTjhxNkhYV1diWWxEdHA2aXhJcW5OZk5HcEs3empKcEVTdWJKYWZkSFpDWWs3TjN5Z2NNelRmN2NQMFJIcU1IS2Rvc0VzUUhtWW1udFJPanRmOUloQTdySlZraVRqTWJKc2Z6Q3FwU1lwamJpczR1aTM5VHp4SU5WT3VTR2VPNk5Tc1lTVHhIRDlqVmdDcFlYcFRPVzZTRjZ2QXhzODVNcFBkRXc2bEJsODYzU21pOUlTajJhaTNMNit4ZEptbUQvSTZvSmxJamVWWlRTNU9ucnRPemJMMHZLdkF0K3BCWnRFQWJtdWtnc0xKQW1IcEhISGtLbkFHczZ3Wm12UzRVT0lxclRMUmZSVjhIL1BrYUQ1T2pkbXF6SFN5d0hQSGo0S0pBdkVDbTVMNk9GSm5tUFcrZ2oyVXpsSHVjZkJVcEZ3cTArMkFTcHVWcHF0TXIva0V4N1lyUks1Zm9qQlROaWdlMmZnUk5qMkRFWFVlWVNiZlJqSmRSMnRFMXR4alBDeGUwbVN0T0thSmVvZUg4WmhtRUo1dlBjM1BBSEpNOHVOQWNBZW1Kb2xWNWRINjFhRjNVak5Fc2RoVzRKclIyOFFqcEdMU29zU3Fqc2hlWTVlTGwzUmlZWk9UclcrS2xIaGw0NTgrRFRUNDlSRWpxc0YzQmthVURJN08wT2dLalZZeXJXeEhEQkg2dWlzUWJSZEd1KzlJYnRlZUhRRnN6dzdFVXZ0TjNuVFRCVjN1N040RHZJQ1lvaGZ4Ym9zRjRwb0dZbm8vMDJXM3pmS3V3ZmNacmkyZzZaMDdwSTF1cEdXY3V1ZmllblJ4K1FXSlNzQnFSa2VMc2RiMjFvVVdaQjFHeTlzYXYxSENERDdvMkM1Nk5hbUp0VG5hZGJWZGZTdlIzVTVxWWhndDcxeDFLcnRIUmlleTl2Q2Rhc2xtT01hcmFWc0o2eE1KR3o3MXpra09sZUZUN3lvQUFYOFA4UGNBUDRmd0ZRL093ZnpjTUVCdi9vM3JoZ0Y2Zkc4TWVIeHZiQUg2RnFEZkFQZ05nTjhJK0NEd0Q0SytMeUFFdmx0Zy9oYmd2eFVoek44RytHMkEzd3Z3UHFEZkIvaGV3UGNDZmhEZ0lkQi9DT2JId2Y0NHpHZGhQZ3Z6V1pqUEFUMEg5QnpRSjBBdUQvTjVtTS9EZk42ZGI3SmlzVkZpVTZWeGcrTjVGRVZSYkxaNGdDWStZMEZGbm5nVG1TZytRVXNFUm1jVDJhQk1XRDZzTTJJK3NoZ25kMXAyT3M4YytVMG51WXZYM3diQ2JqTkV1TU91TmhCNkp4emVvYWs1eGZ1b3ZGZnVkams0WDFIRHBwa3EwSnJXd0pROFVxWHBCd1JsMVlWNE5jVjBKYkt0WkZxTXlFTGNzUnMvN0drbkg0cGJUTlRMaW51MWdzUEsvem5zV2lWY3BWNEYxbVBZcXpYS2NBSG12dzd3WG9DYkFSNENlRUJwNUw4VDRMNlRIdHdGK0QwQWh3QWVlY1dETmVETEEzejhGNEREL08wZXY5d0hPWUNIVHpicUd3U1lEc1YzUGNCK2dPTUFwenpHNFFtSWQyZUkvK2dyalhUVSt3MmdaOEIrRnVoZkJZajVlUXdnNWdYMVlqNXVEOUgzbjJ5SWsxOVlMNFRHYS9tNGpnL1JHWVhFTlRBMndid1lVVVVYQzdMSWhsdkUrT2ptb3dmMGl6WGZvSGluZEdOSVo5Qm1LNzVORVhJb094Q0lKZXhIcW9tUGF4VUx5b1ZIdTNvUW9zNk5nVmlXYTNKUmpiWlZMTEhRZkpodnVTWitOWGtLRHE4R1gzcFZYUDlRTDMzeSt0NVBYdithK3RIQS9hZnNSd2ZVais3NjFYOU8vL1JmNmlYRnZkUUx2eEhYYjMzNDhaTXZ2ZkQ3TDZzWGQ3dVhoSmVCSCtHSFI5MUxYUUI4OGNmaStvblVjN0gyeDNmNW43Uno2VnQvSCtSLzBpL3BEK2o1NkttM25udnFyZWVsM01XL2lPc2w5UUw2K1loN3FRdm5ucjc3M05QM3FJdVp4M0wvZnZaT2FYZHgvdm1aK2VkbjFRdEQzLy9sd292YjFjWHVtOHUzUC9HTWVsNW9xLzFKblQvaFh1cDUwSGYraCtMNmtUby82RHFtemorNzU4UGVtWXlNWjRFOGVUMy9rM1MwRjU1ZmVORTFLQ0hhdmNDeWl5L2Y5V3U1SGxJTy9jZDhnYi9ucDl5cjdmeDkzdGJqSE93VDlBTWgyZy9qcUxkVlhpVC9wai9jeC8rYStpUGwwTCtRbndDVmR1OVJVTjhIb2Z5MmtsdXI5V2ltRitWUkg5ckJmVDdYcG44b3Y5WitOMTIzRUlUOXBmaTFGMnZjellwWG83Y3FYbTBXL2FkZjhYcVA2RWRKNE1WZmlHS0svNFdsRzNoRnZ4STFzZzgraS81NmsrTDFqeTB3Tm9ETUpwRGJHcEM5QmZRTCtRSHc0VmFRR1FCZnRvTHNqY0MzV1duc0kvaGxKd2ErSkdHK1IvRnIrRnJGZ3YycFMvSDdEUGE4TFlGWXJnSGFUZURIWm9oaElHUUxlMGxVTE5pUHVzQkg5RGNjeTNyQVl3R2RQWXIvQmJBVDhGUkFwOENEdlEvdG9Vd0tJUEozUTF6NGl5SHlvRy9vajNmbS93WjcrNjhIdnZnRC9yZWtWdUZlZjIycmU4bXpmeGJnR1Y0Z2VaVlVUL05Pd0x1Q2xIc1RJSjQ5eFArSjhtQVA5YzI1YWg2VnZRaDc5TnROYWc2ZXRjWFhySi9OMy9PYVBGdHpzMmYyLzI3emQ5U0ZpWXRQYlAxelhqMnowYjJrL1E5Y04yZlU5NkcyWTQ5NUw2US9YT3ZRMzNPem9vbmRMZVhtSC83NEs5OTFmcTYrNzE2bjFUbCtJekhMRHFzZm5uSVRJL25PdXJjUXVucitleSsvc0wwNnJyN2JXT3R4UFJDUi9tSVBDZGVlVjZIR25ITkx4MmIxTE1SL3hpV2JTM3JQNTJROWxzUTNGOUp6R2ZDdy9ndEN6ZXlacGVzaFd1VGRjL0plQnUyL2cvYWhCdU05QzY0UDdsL3NFUmpYd25PaUNML2Q5bnBjRHMxalBKaS9zMDNPVmJQMWVEUEVoM1p3SDRGLzhwNEUvY2I5aFBiUUwza3ZDQkQxZy95UytEQy80ZmpRRHVwZkRPSGgvWVk5RDNzajZrV0llVWM1cE0rN3gvS0JjUHk0SHNPQXRQcWV2OXJmVS9CYTY5OHBsQmE0OUh1Rit0Y3M3dFo4RGZlTXphNXdQQ3U5aGx0eXRPZEhHQS9ySFc0eDMreHFGbDlZWDdOOE5hT0g3UytUNzM1RjFDdnZGOGoxay9MMzNLdjVHQnYzSDA2dlVNWC9XUEZLTFY4ZGVRM2kreHlsdG5HclJEd0MrTXdlTjdSV0hDbTI3Q09KZGoxY29VTXJqUFN6YzNtcDVvZ1ZiSThVNGVSbnR2SXJYSisxeXRHYWJaalZPK1IvaXhRWFBxWHFCUHI2UUVYdkRmQ0kwYXlIQ2d0M0tONDNSVVZwZkxRcHVuUWlwRmVCRW9Edm92U0JmZ1YwQ0xsWXlGNUM4Yi8xZGdKdFQ1TllZdUJUMEdaUGdHZTVXQVQ5ZXBESFdHS2dOd2x4aFdQcENjVFlHNGlsTytCUElzQ1ArbkJPWEZ1V2VYTFp6cFBKZHQ5aDZHZ0NtK2xib2UzSUo1ZExXa1Viank4YjM0c3lTSTNpZTFHRFFPd2FaeVgzSFI4VUwxQlRrNjgveGpQTThkL3VMVGdtVjQ0K2VJL3dnUzk0aGhJajFMSWZ4SGRNazNsaVRCOG1aZi9zQ2tKZU95NEpHM1A4eUdsbFpoM1Y3VHV6MUpMV2d4TzdneE45Z1ltc3BIWlA1c01hUEZLRGJKZEw4cVd1UTEydVMyRUZTMlliZEcwS3ovcHEreWZ6a1FvRDlBWlZ2VDdkVjNKdGdkcldmbUlRTDFTd2hxNkp5UncxeTFyVWJIK2VXbzV1TDZGdmNGZHFDYmw3Yk5jWUJvTlZqNVBBTmk2c3B6TzByWkltT3pHRVc4czl3Q2Y1dnl0WHJyemVaSWVteXNRbVExTW1GNG5ZcFoyc0xyWWpWN1pPL0k0WER3bDNtQ0ZDdDAwc1luMnp4RXozaFJKOExxZUFNeDFRRmZEem9HY3VoazdGTVRacVZEVDUrbWhjSjBYNUpuRWZEOUNOYjZodWFnYWVoaFNuV2tNMnMrVStUcFdZamhUdjVZRlAvd3NMVXlzWWdqQUFBQT09In0= -->

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["Location"],"name":[1],"type":["fctr"],"align":["left"]},{"label":["Series"],"name":[2],"type":["fctr"],"align":["left"]},{"label":["Court"],"name":[3],"type":["fctr"],"align":["left"]},{"label":["Surface"],"name":[4],"type":["fctr"],"align":["left"]},{"label":["Date"],"name":[5],"type":["date"],"align":["right"]},{"label":["Round"],"name":[6],"type":["fctr"],"align":["left"]},{"label":["BestOf"],"name":[7],"type":["fctr"],"align":["left"]},{"label":["RankNadal"],"name":[8],"type":["dbl"],"align":["right"]},{"label":["RankRival"],"name":[9],"type":["dbl"],"align":["right"]},{"label":["PartidosUlt6Meses"],"name":[10],"type":["int"],"align":["right"]},{"label":["PartidosUlt3Meses"],"name":[11],"type":["int"],"align":["right"]},{"label":["PartidosUltMes"],"name":[12],"type":["int"],"align":["right"]},{"label":["WRUlt6Meses"],"name":[13],"type":["dbl"],"align":["right"]},{"label":["WRUlt3Meses"],"name":[14],"type":["dbl"],"align":["right"]},{"label":["WRUltMes"],"name":[15],"type":["dbl"],"align":["right"]},{"label":["PartidosRivalUlt6Meses"],"name":[16],"type":["int"],"align":["right"]},{"label":["PartidosRivalUlt3Meses"],"name":[17],"type":["int"],"align":["right"]},{"label":["PartidosRivalUltMes"],"name":[18],"type":["int"],"align":["right"]},{"label":["WRRivalUlt6Meses"],"name":[19],"type":["dbl"],"align":["right"]},{"label":["WRRivalUlt3Meses"],"name":[20],"type":["dbl"],"align":["right"]},{"label":["WRRivalUltMes"],"name":[21],"type":["dbl"],"align":["right"]},{"label":["SetsGanadosUltPartido"],"name":[22],"type":["dbl"],"align":["right"]},{"label":["SetsPerdidosUltPartido"],"name":[23],"type":["dbl"],"align":["right"]},{"label":["ResultUltPartido"],"name":[24],"type":["chr"],"align":["left"]},{"label":["RoundUltPartido"],"name":[25],"type":["chr"],"align":["left"]},{"label":["H2HPartidos"],"name":[26],"type":["int"],"align":["right"]},{"label":["H2HGanados"],"name":[27],"type":["int"],"align":["right"]},{"label":["Result"],"name":[28],"type":["fctr"],"align":["left"]}],"data":[{"1":"Melbourne","2":"Grand Slam","3":"Outdoor","4":"Hard","5":"2020-01-21","6":"1st Round","7":"5","8":"1","9":"73","10":"20","11":"8","12":"1","13":"0.9000000","14":"0.7500000","15":"1.0000000","16":"6","17":"1","18":"1","19":"0.1666667","20":"0.0000000","21":"0.0000000","22":"2","23":"1","24":"Win","25":"Round Robin","26":"0","27":"0","28":"Win"},{"1":"Melbourne","2":"Grand Slam","3":"Outdoor","4":"Hard","5":"2020-01-23","6":"2nd Round","7":"5","8":"1","9":"76","10":"21","11":"9","12":"2","13":"0.9047619","14":"0.7777778","15":"1.0000000","16":"7","17":"3","18":"3","19":"0.1428571","20":"0.3333333","21":"0.3333333","22":"3","23":"0","24":"Win","25":"1st Round","26":"2","27":"2","28":"Win"},{"1":"Melbourne","2":"Grand Slam","3":"Outdoor","4":"Hard","5":"2020-01-25","6":"3rd Round","7":"5","8":"1","9":"30","10":"22","11":"10","12":"3","13":"0.9090909","14":"0.8000000","15":"1.0000000","16":"33","17":"5","18":"5","19":"0.6666667","20":"0.6000000","21":"0.6000000","22":"3","23":"0","24":"Win","25":"2nd Round","26":"1","27":"1","28":"Win"},{"1":"Melbourne","2":"Grand Slam","3":"Outdoor","4":"Hard","5":"2020-01-27","6":"4th Round","7":"5","8":"1","9":"26","10":"23","11":"11","12":"4","13":"0.9130435","14":"0.8181818","15":"1.0000000","16":"15","17":"4","18":"4","19":"0.6666667","20":"0.7500000","21":"0.7500000","22":"3","23":"0","24":"Win","25":"3rd Round","26":"7","27":"4","28":"Win"},{"1":"Melbourne","2":"Grand Slam","3":"Outdoor","4":"Hard","5":"2020-01-29","6":"Quarterfinals","7":"5","8":"1","9":"5","10":"24","11":"10","12":"5","13":"0.8750000","14":"0.7000000","15":"0.8000000","16":"30","17":"10","18":"5","19":"0.8000000","20":"0.8000000","21":"1.0000000","22":"3","23":"1","24":"Win","25":"4th Round","26":"13","27":"9","28":"Lose"},{"1":"Acapulco","2":"ATP500","3":"Outdoor","4":"Hard","5":"2020-02-26","6":"1st Round","7":"3","8":"2","9":"54","10":"18","11":"6","12":"2","13":"0.8333333","14":"0.8333333","15":"0.5000000","16":"17","17":"9","18":"6","19":"0.2352941","20":"0.2222222","21":"0.3333333","22":"1","23":"3","24":"Lose","25":"Quarterfinals","26":"3","27":"3","28":"Win"},{"1":"Acapulco","2":"ATP500","3":"Outdoor","4":"Hard","5":"2020-02-27","6":"2nd Round","7":"3","8":"2","9":"50","10":"18","11":"7","12":"3","13":"0.8333333","14":"0.8571429","15":"0.6666667","16":"20","17":"13","18":"8","19":"0.5000000","20":"0.6153846","21":"0.6250000","22":"2","23":"0","24":"Win","25":"1st Round","26":"0","27":"0","28":"Win"},{"1":"Acapulco","2":"ATP500","3":"Outdoor","4":"Hard","5":"2020-02-28","6":"Quarterfinals","7":"3","8":"2","9":"76","10":"19","11":"8","12":"3","13":"0.8421053","14":"0.8750000","15":"1.0000000","16":"16","17":"12","18":"11","19":"0.5625000","20":"0.5833333","21":"0.6363636","22":"2","23":"0","24":"Win","25":"2nd Round","26":"0","27":"0","28":"Win"},{"1":"Acapulco","2":"ATP500","3":"Outdoor","4":"Hard","5":"2020-02-29","6":"Semifinals","7":"3","8":"2","9":"22","10":"20","11":"9","12":"4","13":"0.8500000","14":"0.8888889","15":"1.0000000","16":"22","17":"9","18":"7","19":"0.5454545","20":"0.5555556","21":"0.5714286","22":"2","23":"0","24":"Win","25":"Quarterfinals","26":"13","27":"12","28":"Win"},{"1":"Acapulco","2":"ATP500","3":"Outdoor","4":"Hard","5":"2020-03-01","6":"The Final","7":"3","8":"2","9":"35","10":"20","11":"10","12":"5","13":"0.8500000","14":"0.9000000","15":"1.0000000","16":"19","17":"10","18":"6","19":"0.4736842","20":"0.6000000","21":"0.6666667","22":"2","23":"0","24":"Win","25":"Semifinals","26":"0","27":"0","28":"Win"},{"1":"Rome","2":"Masters 1000","3":"Outdoor","4":"Clay","5":"2020-09-16","6":"2nd Round","7":"3","8":"2","9":"18","10":"1","11":"1","12":"1","13":"1.0000000","14":"1.0000000","15":"1.0000000","16":"9","17":"9","18":"9","19":"0.6666667","20":"0.6666667","21":"0.6666667","22":"2","23":"0","24":"Win","25":"The Final","26":"2","27":"2","28":"Win"},{"1":"Rome","2":"Masters 1000","3":"Outdoor","4":"Clay","5":"2020-09-18","6":"3rd Round","7":"3","8":"2","9":"25","10":"2","11":"2","12":"2","13":"1.0000000","14":"1.0000000","15":"1.0000000","16":"6","17":"6","18":"6","19":"0.3333333","20":"0.3333333","21":"0.3333333","22":"2","23":"0","24":"Win","25":"2nd Round","26":"2","27":"2","28":"Win"},{"1":"Rome","2":"Masters 1000","3":"Outdoor","4":"Clay","5":"2020-09-19","6":"Quarterfinals","7":"3","8":"2","9":"15","10":"3","11":"3","12":"3","13":"0.6666667","14":"0.6666667","15":"0.6666667","16":"8","17":"8","18":"8","19":"0.6250000","20":"0.6250000","21":"0.6250000","22":"2","23":"0","24":"Win","25":"3rd Round","26":"8","27":"8","28":"Lose"},{"1":"Paris","2":"Grand Slam","3":"Outdoor","4":"Clay","5":"2020-09-28","6":"1st Round","7":"5","8":"2","9":"83","10":"4","11":"4","12":"4","13":"0.7500000","14":"0.7500000","15":"0.7500000","16":"3","17":"3","18":"3","19":"0.3333333","20":"0.3333333","21":"0.3333333","22":"0","23":"2","24":"Lose","25":"Quarterfinals","26":"0","27":"0","28":"Win"},{"1":"Paris","2":"Grand Slam","3":"Outdoor","4":"Clay","5":"2020-09-30","6":"2nd Round","7":"5","8":"2","9":"236","10":"5","11":"5","12":"5","13":"0.8000000","14":"0.8000000","15":"0.8000000","16":"4","17":"4","18":"3","19":"0.2500000","20":"0.2500000","21":"0.3333333","22":"3","23":"0","24":"Win","25":"1st Round","26":"0","27":"0","28":"Win"},{"1":"Paris","2":"Grand Slam","3":"Outdoor","4":"Clay","5":"2020-10-02","6":"3rd Round","7":"5","8":"2","9":"74","10":"6","11":"6","12":"6","13":"0.8333333","14":"0.8333333","15":"0.8333333","16":"7","17":"7","18":"6","19":"0.5714286","20":"0.5714286","21":"0.6666667","22":"3","23":"0","24":"Win","25":"2nd Round","26":"0","27":"0","28":"Win"},{"1":"Paris","2":"Grand Slam","3":"Outdoor","4":"Clay","5":"2020-10-04","6":"4th Round","7":"5","8":"2","9":"213","10":"7","11":"7","12":"7","13":"0.8571429","14":"0.8571429","15":"0.8571429","16":"6","17":"6","18":"4","19":"0.5000000","20":"0.5000000","21":"0.7500000","22":"3","23":"0","24":"Win","25":"3rd Round","26":"0","27":"0","28":"Win"},{"1":"Paris","2":"Grand Slam","3":"Outdoor","4":"Clay","5":"2020-10-06","6":"Quarterfinals","7":"5","8":"2","9":"75","10":"8","11":"8","12":"8","13":"0.8750000","14":"0.8750000","15":"0.8750000","16":"11","17":"11","18":"10","19":"0.6363636","20":"0.6363636","21":"0.7000000","22":"3","23":"0","24":"Win","25":"4th Round","26":"0","27":"0","28":"Win"},{"1":"Paris","2":"Grand Slam","3":"Outdoor","4":"Clay","5":"2020-10-09","6":"Semifinals","7":"5","8":"2","9":"14","10":"9","11":"9","12":"9","13":"0.8888889","14":"0.8888889","15":"0.8888889","16":"16","17":"16","18":"13","19":"0.6875000","20":"0.6875000","21":"0.7692308","22":"3","23":"0","24":"Win","25":"Quarterfinals","26":"9","27":"8","28":"Win"},{"1":"Paris","2":"Grand Slam","3":"Outdoor","4":"Clay","5":"2020-10-11","6":"The Final","7":"5","8":"2","9":"1","10":"10","11":"10","12":"10","13":"0.9000000","14":"0.9000000","15":"0.9000000","16":"21","17":"21","18":"12","19":"0.9047619","20":"0.9047619","21":"0.9166667","22":"3","23":"0","24":"Win","25":"Semifinals","26":"52","27":"24","28":"Win"},{"1":"Paris","2":"Masters 1000","3":"Indoor","4":"Hard","5":"2020-11-04","6":"2nd Round","7":"3","8":"2","9":"64","10":"11","11":"11","12":"4","13":"0.9090909","14":"0.9090909","15":"1.0000000","16":"10","17":"10","18":"5","19":"0.4000000","20":"0.4000000","21":"0.4000000","22":"3","23":"0","24":"Win","25":"The Final","26":"12","27":"9","28":"Win"},{"1":"Paris","2":"Masters 1000","3":"Indoor","4":"Hard","5":"2020-11-05","6":"3rd Round","7":"3","8":"2","9":"61","10":"12","11":"12","12":"4","13":"0.9166667","14":"0.9166667","15":"1.0000000","16":"14","17":"14","18":"7","19":"0.5000000","20":"0.5000000","21":"0.4285714","22":"2","23":"1","24":"Win","25":"2nd Round","26":"0","27":"0","28":"Win"},{"1":"Paris","2":"Masters 1000","3":"Indoor","4":"Hard","5":"2020-11-06","6":"Quarterfinals","7":"3","8":"2","9":"15","10":"13","11":"13","12":"5","13":"0.9230769","14":"0.9230769","15":"1.0000000","16":"21","17":"21","18":"7","19":"0.6666667","20":"0.6666667","21":"0.5714286","22":"2","23":"0","24":"Win","25":"3rd Round","26":"3","27":"3","28":"Win"},{"1":"Paris","2":"Masters 1000","3":"Indoor","4":"Hard","5":"2020-11-07","6":"Semifinals","7":"3","8":"2","9":"7","10":"14","11":"14","12":"6","13":"0.8571429","14":"0.8571429","15":"0.8333333","16":"24","17":"24","18":"12","19":"0.8750000","20":"0.8750000","21":"1.0000000","22":"2","23":"1","24":"Win","25":"Quarterfinals","26":"5","27":"4","28":"Lose"},{"1":"London","2":"Masters Cup","3":"Indoor","4":"Hard","5":"2020-11-15","6":"Round Robin","7":"3","8":"2","9":"8","10":"15","11":"15","12":"5","13":"0.8666667","14":"0.8666667","15":"0.8000000","16":"31","17":"31","18":"10","19":"0.8064516","20":"0.8064516","21":"0.8000000","22":"0","23":"2","24":"Lose","25":"Semifinals","26":"1","27":"1","28":"Win"},{"1":"London","2":"Masters Cup","3":"Indoor","4":"Hard","5":"2020-11-17","6":"Round Robin","7":"3","8":"2","9":"3","10":"16","11":"16","12":"6","13":"0.8125000","14":"0.8125000","15":"0.6666667","16":"18","17":"18","18":"5","19":"0.8333333","20":"0.8333333","21":"0.8000000","22":"2","23":"0","24":"Win","25":"Round Robin","26":"14","27":"9","28":"Lose"},{"1":"London","2":"Masters Cup","3":"Indoor","4":"Hard","5":"2020-11-19","6":"Round Robin","7":"3","8":"2","9":"6","10":"17","11":"17","12":"7","13":"0.8235294","14":"0.8235294","15":"0.7142857","16":"25","17":"25","18":"6","19":"0.6400000","20":"0.6400000","21":"0.3333333","22":"0","23":"2","24":"Lose","25":"Round Robin","26":"6","27":"5","28":"Win"},{"1":"London","2":"Masters Cup","3":"Indoor","4":"Hard","5":"2020-11-21","6":"Semifinals","7":"3","8":"2","9":"4","10":"18","11":"18","12":"8","13":"0.7777778","14":"0.7777778","15":"0.6250000","16":"25","17":"25","18":"12","19":"0.7600000","20":"0.7600000","21":"0.9166667","22":"2","23":"1","24":"Win","25":"Round Robin","26":"3","27":"3","28":"Lose"},{"1":"Melbourne","2":"Grand Slam","3":"Outdoor","4":"Hard","5":"2021-02-09","6":"1st Round","7":"5","8":"2","9":"56","10":"19","11":"5","12":"1","13":"0.7894737","14":"0.6000000","15":"1.0000000","16":"15","17":"3","18":"2","19":"0.5333333","20":"0.0000000","21":"0.0000000","22":"1","23":"2","24":"Lose","25":"Semifinals","26":"0","27":"0","28":"Win"},{"1":"Melbourne","2":"Grand Slam","3":"Outdoor","4":"Hard","5":"2021-02-11","6":"2nd Round","7":"5","8":"2","9":"177","10":"20","11":"6","12":"2","13":"0.8000000","14":"0.6666667","15":"1.0000000","16":"6","17":"3","18":"3","19":"0.3333333","20":"0.3333333","21":"0.3333333","22":"3","23":"0","24":"Win","25":"1st Round","26":"0","27":"0","28":"Win"},{"1":"Melbourne","2":"Grand Slam","3":"Outdoor","4":"Hard","5":"2021-02-13","6":"3rd Round","7":"5","8":"2","9":"69","10":"21","11":"6","12":"3","13":"0.8095238","14":"0.6666667","15":"1.0000000","16":"19","17":"8","18":"4","19":"0.5263158","20":"0.6250000","21":"0.5000000","22":"3","23":"0","24":"Win","25":"2nd Round","26":"0","27":"0","28":"Win"},{"1":"Melbourne","2":"Grand Slam","3":"Outdoor","4":"Hard","5":"2021-02-15","6":"4th Round","7":"5","8":"2","9":"17","10":"22","11":"6","12":"4","13":"0.8181818","14":"0.8333333","15":"1.0000000","16":"11","17":"6","18":"4","19":"0.4545455","20":"0.6666667","21":"0.7500000","22":"3","23":"0","24":"Win","25":"3rd Round","26":"16","27":"12","28":"Win"},{"1":"Melbourne","2":"Grand Slam","3":"Outdoor","4":"Hard","5":"2021-02-17","6":"Quarterfinals","7":"5","8":"2","9":"6","10":"23","11":"6","12":"5","13":"0.7826087","14":"0.6666667","15":"0.8000000","16":"30","17":"5","18":"5","19":"0.7000000","20":"1.0000000","21":"1.0000000","22":"3","23":"0","24":"Win","25":"4th Round","26":"7","27":"6","28":"Lose"},{"1":"Monte Carlo","2":"Masters 1000","3":"Outdoor","4":"Clay","5":"2021-04-14","6":"2nd Round","7":"3","8":"3","9":"87","10":"14","11":"6","12":"1","13":"0.7142857","14":"0.8333333","15":"1.0000000","16":"16","17":"14","18":"5","19":"0.4375000","20":"0.5000000","21":"0.4000000","22":"2","23":"3","24":"Lose","25":"Quarterfinals","26":"3","27":"3","28":"Win"},{"1":"Monte Carlo","2":"Masters 1000","3":"Outdoor","4":"Clay","5":"2021-04-15","6":"3rd Round","7":"3","8":"3","9":"17","10":"15","11":"7","12":"2","13":"0.7333333","14":"0.8571429","15":"1.0000000","16":"21","17":"15","18":"7","19":"0.6666667","20":"0.6666667","21":"0.5714286","22":"2","23":"0","24":"Win","25":"2nd Round","26":"14","27":"13","28":"Win"},{"1":"Monte Carlo","2":"Masters 1000","3":"Outdoor","4":"Clay","5":"2021-04-16","6":"Quarterfinals","7":"3","8":"3","9":"8","10":"16","11":"8","12":"3","13":"0.6875000","14":"0.7500000","15":"0.6666667","16":"35","17":"25","18":"10","19":"0.8000000","20":"0.8400000","21":"0.8000000","22":"2","23":"0","24":"Win","25":"3rd Round","26":"2","27":"2","28":"Lose"},{"1":"Barcelona","2":"ATP500","3":"Outdoor","4":"Clay","5":"2021-04-21","6":"2nd Round","7":"3","8":"3","9":"111","10":"17","11":"9","12":"4","13":"0.7058824","14":"0.7777778","15":"0.7500000","16":"8","17":"8","18":"7","19":"0.5000000","20":"0.5000000","21":"0.5714286","22":"1","23":"2","24":"Lose","25":"Quarterfinals","26":"0","27":"0","28":"Win"},{"1":"Barcelona","2":"ATP500","3":"Outdoor","4":"Clay","5":"2021-04-22","6":"3rd Round","7":"3","8":"3","9":"39","10":"18","11":"10","12":"5","13":"0.7222222","14":"0.8000000","15":"0.8000000","16":"14","17":"14","18":"5","19":"0.5714286","20":"0.5714286","21":"0.6000000","22":"2","23":"1","24":"Win","25":"2nd Round","26":"12","27":"11","28":"Win"},{"1":"Barcelona","2":"ATP500","3":"Outdoor","4":"Clay","5":"2021-04-23","6":"Quarterfinals","7":"3","8":"3","9":"58","10":"19","11":"11","12":"6","13":"0.7368421","14":"0.8181818","15":"0.8333333","16":"23","17":"18","18":"6","19":"0.6086957","20":"0.6111111","21":"0.6666667","22":"2","23":"1","24":"Win","25":"3rd Round","26":"1","27":"1","28":"Win"},{"1":"Barcelona","2":"ATP500","3":"Outdoor","4":"Clay","5":"2021-04-24","6":"Semifinals","7":"3","8":"3","9":"13","10":"20","11":"12","12":"7","13":"0.7500000","14":"0.8333333","15":"0.8571429","16":"20","17":"15","18":"11","19":"0.7000000","20":"0.7333333","21":"0.8181818","22":"2","23":"0","24":"Win","25":"Quarterfinals","26":"4","27":"4","28":"Win"},{"1":"Barcelona","2":"ATP500","3":"Outdoor","4":"Clay","5":"2021-04-25","6":"The Final","7":"3","8":"3","9":"5","10":"21","11":"13","12":"8","13":"0.7619048","14":"0.8461538","15":"0.8750000","16":"37","17":"31","18":"14","19":"0.7297297","20":"0.8064516","21":"0.8571429","22":"2","23":"0","24":"Win","25":"Semifinals","26":"8","27":"6","28":"Win"},{"1":"Madrid","2":"Masters 1000","3":"Outdoor","4":"Clay","5":"2021-05-05","6":"2nd Round","7":"3","8":"2","9":"120","10":"19","11":"14","12":"9","13":"0.7368421","14":"0.8571429","15":"0.8888889","16":"15","17":"12","18":"8","19":"0.4666667","20":"0.4166667","21":"0.5000000","22":"2","23":"1","24":"Win","25":"The Final","26":"0","27":"0","28":"Win"},{"1":"Madrid","2":"Masters 1000","3":"Outdoor","4":"Clay","5":"2021-05-06","6":"3rd Round","7":"3","8":"2","9":"76","10":"19","11":"15","12":"10","13":"0.7894737","14":"0.8666667","15":"0.9000000","16":"23","17":"20","18":"8","19":"0.6521739","20":"0.6500000","21":"0.5000000","22":"2","23":"0","24":"Win","25":"2nd Round","26":"0","27":"0","28":"Win"},{"1":"Madrid","2":"Masters 1000","3":"Outdoor","4":"Clay","5":"2021-05-07","6":"Quarterfinals","7":"3","8":"2","9":"6","10":"20","11":"16","12":"11","13":"0.7500000","14":"0.8125000","15":"0.8181818","16":"22","17":"19","18":"7","19":"0.6818182","20":"0.7368421","21":"0.7142857","22":"2","23":"0","24":"Win","25":"3rd Round","26":"6","27":"4","28":"Lose"},{"1":"Rome","2":"Masters 1000","3":"Outdoor","4":"Clay","5":"2021-05-12","6":"2nd Round","7":"3","8":"3","9":"18","10":"21","11":"15","12":"12","13":"0.7619048","14":"0.8000000","15":"0.8333333","16":"30","17":"23","18":"10","19":"0.7000000","20":"0.6521739","21":"0.6000000","22":"0","23":"2","24":"Lose","25":"Quarterfinals","26":"1","27":"1","28":"Win"},{"1":"Rome","2":"Masters 1000","3":"Outdoor","4":"Clay","5":"2021-05-13","6":"3rd Round","7":"3","8":"3","9":"14","10":"22","11":"16","12":"13","13":"0.7727273","14":"0.8125000","15":"0.8461538","16":"19","17":"16","18":"8","19":"0.5789474","20":"0.5625000","21":"0.5000000","22":"2","23":"0","24":"Win","25":"2nd Round","26":"3","27":"1","28":"Win"},{"1":"Rome","2":"Masters 1000","3":"Outdoor","4":"Clay","5":"2021-05-14","6":"Quarterfinals","7":"3","8":"3","9":"6","10":"22","11":"16","12":"13","13":"0.7727273","14":"0.8125000","15":"0.8461538","16":"27","17":"21","18":"11","19":"0.7037037","20":"0.7142857","21":"0.7272727","22":"2","23":"1","24":"Win","25":"3rd Round","26":"7","27":"4","28":"Win"},{"1":"Rome","2":"Masters 1000","3":"Outdoor","4":"Clay","5":"2021-05-15","6":"Semifinals","7":"3","8":"3","9":"47","10":"23","11":"17","12":"13","13":"0.7826087","14":"0.8235294","15":"0.8461538","16":"14","17":"10","18":"6","19":"0.4285714","20":"0.4000000","21":"0.6666667","22":"2","23":"0","24":"Win","25":"Quarterfinals","26":"0","27":"0","28":"Win"},{"1":"Rome","2":"Masters 1000","3":"Outdoor","4":"Clay","5":"2021-05-16","6":"The Final","7":"3","8":"3","9":"1","10":"23","11":"17","12":"13","13":"0.8260870","14":"0.8235294","15":"0.9230769","16":"20","17":"13","18":"8","19":"0.7500000","20":"0.7692308","21":"0.7500000","22":"2","23":"0","24":"Win","25":"Semifinals","26":"53","27":"25","28":"Win"}],"options":{"columns":{"min":{},"max":[10],"total":[28]},"rows":{"min":[10],"max":[10],"total":[49]},"pages":{}}}
  </script>
</div>

<!-- rnb-frame-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuXG5kZl9tYXRjaGVzX3RyYWluIDwtIGRmX21hdGNoZXMgJT4lIFxuICBmaWx0ZXIoRGF0ZSA8IFwiMjAyMC0wMS0wMVwiKVxuICBcbmRmX21hdGNoZXNfdGVzdCA8LSBkZl9tYXRjaGVzICU+JSBcbiAgZmlsdGVyKERhdGUgPj0gXCIyMDIwLTAxLTAxXCIpXG5cbiMgQ09NUFVUTyBMQVMgVEFTQVMgREUgQ09SVEUgIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyNcblxuIyBQcm9iYWJpbGlkYWQgaGlzdMOzcmljYSBkZSB2aWN0b3JpYSBOYWRhbCA9PT09PT09PT09PT09PT09PT09PT1cblxuZGZfbWF0Y2hlcyAlPiUgXG4gIHB1bGwoUmVzdWx0KSAlPiUgXG4gIHRhYmxlKCkgJT4lIFxuICBwcm9wLnRhYmxlKCkgIyBMYSBwcm9iYWJpbGlkYWQgaGlzdMOzcmljYSBlcyA4Myw5JS5cbmBgYCJ9 -->

```r

df_matches_train <- df_matches %>% 
  filter(Date < "2020-01-01")
  
df_matches_test <- df_matches %>% 
  filter(Date >= "2020-01-01")

# COMPUTO LAS TASAS DE CORTE ###################################

# Probabilidad histórica de victoria Nadal =====================

df_matches %>% 
  pull(Result) %>% 
  table() %>% 
  prop.table() # La probabilidad histórica es 83,9%.
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiLlxuICAgICBMb3NlICAgICAgIFdpbiBcbjAuMTYwMjk4MiAwLjgzOTcwMTggXG4ifQ== -->

```
.
     Lose       Win 
0.1602982 0.8397018 
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuI1NpIGRpZ28gZ2FuYSwgYWNpZXJ0byBlbCA4MyUgZGUgbGFzIHZlY2VzLlxuXG4jIFByb2JhYmlsaWRhZCB1bHRpbW9zIDIgYcOxb3MgPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PVxuXG5kZl9tYXRjaGVzICU+JSBcbiAgZmlsdGVyKERhdGUgPiB5bWQoXCIyMDE5LTAxLTAxXCIpKSAlPiUgXG4gIHB1bGwoUmVzdWx0KSAlPiUgXG4gIHRhYmxlKCkgJT4lIFxuICBwcm9wLnRhYmxlKCkgIzg0LDMlIGRlIGxhcyB2ZWNlcyBnYW7Ds1xuYGBgIn0= -->

```r
#Si digo gana, acierto el 83% de las veces.

# Probabilidad ultimos 2 años ==================================

df_matches %>% 
  filter(Date > ymd("2019-01-01")) %>% 
  pull(Result) %>% 
  table() %>% 
  prop.table() #84,3% de las veces ganó
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiLlxuICAgICBMb3NlICAgICAgIFdpbiBcbjAuMTUxNzg1NyAwLjg0ODIxNDMgXG4ifQ== -->

```
.
     Lose       Win 
0.1517857 0.8482143 
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuI1Byb2JhYmlsaWRhZCAyMDIwIGVuIGFkZWxhbnRlID09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PVxuXG5kZl9tYXRjaGVzICU+JSBcbiAgZmlsdGVyKERhdGUgPiB5bWQoXCIyMDIwLTAxLTAxXCIpKSAlPiUgXG4gIHB1bGwoUmVzdWx0KSAlPiUgXG4gIHRhYmxlKCkgJT4lIFxuICBwcm9wLnRhYmxlKCkgIzgxLDglIGRlIGxhcyB2ZWNlcyBnYW7Ds1xuYGBgIn0= -->

```r
#Probabilidad 2020 en adelante =================================

df_matches %>% 
  filter(Date > ymd("2020-01-01")) %>% 
  pull(Result) %>% 
  table() %>% 
  prop.table() #81,8% de las veces ganó
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiLlxuICAgICBMb3NlICAgICAgIFdpbiBcbjAuMTYzMjY1MyAwLjgzNjczNDcgXG4ifQ== -->

```
.
     Lose       Win 
0.1632653 0.8367347 
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuI1Byb2JhYmlsaWRhZCBwb3N0IGN1YXJlbnRlbmEgPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PVxuXG5kZl9tYXRjaGVzICU+JSBcbiAgZmlsdGVyKERhdGUgPiB5bWQoXCIyMDIwLTA4LTAxXCIpKSAlPiUgXG4gIHB1bGwoUmVzdWx0KSAlPiUgXG4gIHRhYmxlKCkgJT4lIFxuICBwcm9wLnRhYmxlKCkgIzc4LDI2JSBkZSBsYXMgdmVjZXMgZ2Fuw7MuXG5gYGAifQ== -->

```r
#Probabilidad post cuarentena ==================================

df_matches %>% 
  filter(Date > ymd("2020-08-01")) %>% 
  pull(Result) %>% 
  table() %>% 
  prop.table() #78,26% de las veces ganó.
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiLlxuICAgICBMb3NlICAgICAgIFdpbiBcbjAuMTc5NDg3MiAwLjgyMDUxMjggXG4ifQ== -->

```
.
     Lose       Win 
0.1794872 0.8205128 
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuI1Byb2JhYmlsaWRhZCAyMDIxID09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PVxuXG5kZl9tYXRjaGVzICU+JSBcbiAgZmlsdGVyKERhdGUgPiB5bWQoXCIyMDIwLTEyLTMxXCIpKSAlPiUgXG4gIHB1bGwoUmVzdWx0KSAlPiUgXG4gIHRhYmxlKCkgJT4lIFxuICBwcm9wLnRhYmxlKCkgIzgwJSBwZXJvIGNvbiBwb2NvcyBwYXJ0aWRvcyBqdWdhZG9zLlxuYGBgIn0= -->

```r
#Probabilidad 2021 =============================================

df_matches %>% 
  filter(Date > ymd("2020-12-31")) %>% 
  pull(Result) %>% 
  table() %>% 
  prop.table() #80% pero con pocos partidos jugados.
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiLlxuICAgICBMb3NlICAgICAgIFdpbiBcbjAuMTQyODU3MSAwLjg1NzE0MjkgXG4ifQ== -->

```
.
     Lose       Win 
0.1428571 0.8571429 
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuIyBFbiBkZWZpbml0aXZhLCBzaSB5byBkaWdvIHF1ZSBnYW5hIG5hZGFsIHNpZW1wcmVcbiMgdm95IGEgYWNlcnRhciB1biA4MCUuIE5lY2VzaXRvIHVuIG1vZGVsbyBxdWUgc3VwZXJlIGNsYXJhbWVudGUgZXNlIG5yb1xuIyBPIHNlYSB1biBtb2RlbG8gZGUgKyBkZSA4NSUgZGUgYWNpZXJ0by5cblxuI0VuIGNsYXkgMjAxOSBlbiBhZGVsYW50ZVxuXG5kZl9tYXRjaGVzICU+JSBcbiAgZmlsdGVyKERhdGUgPiB5bWQoXCIyMDE4LTEyLTMxXCIpICYgXG4gICAgICAgICAgIFN1cmZhY2UgPT0gXCJDbGF5XCIpICU+JSBcbiAgcHVsbChSZXN1bHQpICU+JSBcbiAgdGFibGUoKSAlPiUgXG4gIHByb3AudGFibGUoKSAjOTAlIGVuIGNsYXlcbmBgYCJ9 -->

```r
# En definitiva, si yo digo que gana nadal siempre
# voy a acertar un 80%. Necesito un modelo que supere claramente ese nro
# O sea un modelo de + de 85% de acierto.

#En clay 2019 en adelante

df_matches %>% 
  filter(Date > ymd("2018-12-31") & 
           Surface == "Clay") %>% 
  pull(Result) %>% 
  table() %>% 
  prop.table() #90% en clay
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiLlxuTG9zZSAgV2luIFxuMC4xMiAwLjg4IFxuIn0= -->

```
.
Lose  Win 
0.12 0.88 
```



<!-- rnb-output-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->


Necesito un modelo que acierte por encima del 80% de las veces.

###Prueba de Variables

Arranco probando una serie de modelos logit para ver cuales son las variables con mayor impacto en el resultado del partido.


<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuXG4jTW9kZWxvIDFcblxuZ2xtLmZpdDEgPC0gZ2xtKFJlc3VsdCB+IENvdXJ0ICsgU3VyZmFjZSArIFJvdW5kICsgQmVzdE9mICsgUmFua05hZGFsICsgUmFua1JpdmFsICsgUGFydGlkb3NVbHQ2TWVzZXMgK1xuICAgICAgICAgICAgICAgIFBhcnRpZG9zVWx0M01lc2VzICsgUGFydGlkb3NVbHRNZXMgKyAgV1JVbHQ2TWVzZXMgKyBXUlVsdDNNZXNlcyArIFdSVWx0TWVzICsgXG4gICAgICAgICAgICAgICAgUGFydGlkb3NSaXZhbFVsdDZNZXNlcyArIFBhcnRpZG9zUml2YWxVbHQzTWVzZXMgKyBQYXJ0aWRvc1JpdmFsVWx0TWVzICtcbiAgICAgICAgICAgICAgICBXUlJpdmFsVWx0Nk1lc2VzICsgV1JSaXZhbFVsdDNNZXNlcyArIFdSUml2YWxVbHRNZXMgK1xuICAgICAgICAgICAgICAgIFNldHNHYW5hZG9zVWx0UGFydGlkbyArIFNldHNQZXJkaWRvc1VsdFBhcnRpZG8gK1xuICAgICAgICAgICAgICAgIFJlc3VsdFVsdFBhcnRpZG8gKyBSb3VuZFVsdFBhcnRpZG8gKyBcbiAgICAgICAgICAgICAgICBIMkhQYXJ0aWRvcyArIEgySEdhbmFkb3MsXG4gICAgICAgICAgICAgICBkYXRhID0gZGZfbWF0Y2hlc190cmFpbixcbiAgICAgICAgICAgICAgIGZhbWlseSA9IGJpbm9taWFsKGxpbmsgPSBcImxvZ2l0XCIpKVxuYGBgIn0= -->

```r

#Modelo 1

glm.fit1 <- glm(Result ~ Court + Surface + Round + BestOf + RankNadal + RankRival + PartidosUlt6Meses +
                PartidosUlt3Meses + PartidosUltMes +  WRUlt6Meses + WRUlt3Meses + WRUltMes + 
                PartidosRivalUlt6Meses + PartidosRivalUlt3Meses + PartidosRivalUltMes +
                WRRivalUlt6Meses + WRRivalUlt3Meses + WRRivalUltMes +
                SetsGanadosUltPartido + SetsPerdidosUltPartido +
                ResultUltPartido + RoundUltPartido + 
                H2HPartidos + H2HGanados,
               data = df_matches_train,
               family = binomial(link = "logit"))
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkXG4ifQ== -->

```
glm.fit: fitted probabilities numerically 0 or 1 occurred
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuc3VtbWFyeShnbG0uZml0MSlcbmBgYCJ9 -->

```r
summary(glm.fit1)
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiXG5DYWxsOlxuZ2xtKGZvcm11bGEgPSBSZXN1bHQgfiBDb3VydCArIFN1cmZhY2UgKyBSb3VuZCArIEJlc3RPZiArIFJhbmtOYWRhbCArIFxuICAgIFJhbmtSaXZhbCArIFBhcnRpZG9zVWx0Nk1lc2VzICsgUGFydGlkb3NVbHQzTWVzZXMgKyBQYXJ0aWRvc1VsdE1lcyArIFxuICAgIFdSVWx0Nk1lc2VzICsgV1JVbHQzTWVzZXMgKyBXUlVsdE1lcyArIFBhcnRpZG9zUml2YWxVbHQ2TWVzZXMgKyBcbiAgICBQYXJ0aWRvc1JpdmFsVWx0M01lc2VzICsgUGFydGlkb3NSaXZhbFVsdE1lcyArIFdSUml2YWxVbHQ2TWVzZXMgKyBcbiAgICBXUlJpdmFsVWx0M01lc2VzICsgV1JSaXZhbFVsdE1lcyArIFNldHNHYW5hZG9zVWx0UGFydGlkbyArIFxuICAgIFNldHNQZXJkaWRvc1VsdFBhcnRpZG8gKyBSZXN1bHRVbHRQYXJ0aWRvICsgUm91bmRVbHRQYXJ0aWRvICsgXG4gICAgSDJIUGFydGlkb3MgKyBIMkhHYW5hZG9zLCBmYW1pbHkgPSBiaW5vbWlhbChsaW5rID0gXCJsb2dpdFwiKSwgXG4gICAgZGF0YSA9IGRmX21hdGNoZXNfdHJhaW4pXG5cbkRldmlhbmNlIFJlc2lkdWFsczogXG4gICAgIE1pbiAgICAgICAgMVEgICAgTWVkaWFuICAgICAgICAzUSAgICAgICBNYXggIFxuLTMuMTM5MTMgICAwLjAwMDM1ICAgMC4wMTQyNiAgIDAuMTA1MjYgICAyLjg5MTM4ICBcblxuQ29lZmZpY2llbnRzOlxuICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBFc3RpbWF0ZSAgU3RkLiBFcnJvciB6IHZhbHVlICAgICAgICAgIFByKD58enwpICAgIFxuKEludGVyY2VwdCkgICAgICAgICAgICAgICAgICAgIC0zLjQ0NzUzNCAgICA0LjY1NzUyMCAgLTAuNzQwICAgICAgICAgIDAuNDU5MTc0ICAgIFxuQ291cnRPdXRkb29yICAgICAgICAgICAgICAgICAgICAwLjkxNDM2NiAgICAwLjg3MTg3NiAgIDEuMDQ5ICAgICAgICAgIDAuMjk0MzAxICAgIFxuU3VyZmFjZUNsYXkgICAgICAgICAgICAgICAgICAgICAxLjYyODQwMCAgICAxLjkzMTkxNCAgIDAuODQzICAgICAgICAgIDAuMzk5Mjg3ICAgIFxuU3VyZmFjZUdyYXNzICAgICAgICAgICAgICAgICAgIC0xLjUzNjg1MSAgICAyLjA3NTEwOSAgLTAuNzQxICAgICAgICAgIDAuNDU4OTI5ICAgIFxuU3VyZmFjZUhhcmQgICAgICAgICAgICAgICAgICAgIC0wLjgzNTgzMCAgICAxLjc4MzExOCAgLTAuNDY5ICAgICAgICAgIDAuNjM5MjUxICAgIFxuUm91bmQybmQgUm91bmQgICAgICAgICAgICAgICAgICAzLjkxOTk3MiAgICAxLjQ4NzgxNSAgIDIuNjM1ICAgICAgICAgIDAuMDA4NDIxICoqIFxuUm91bmQzcmQgUm91bmQgICAgICAgICAgICAgICAgIC04LjE2MTE5OSAxMjc5LjUyNTcxNSAgLTAuMDA2ICAgICAgICAgIDAuOTk0OTExICAgIFxuUm91bmQ0dGggUm91bmQgICAgICAgICAgICAgICAgIC0yLjY5MzcxNSAxMjc5LjUyNzE2MCAgLTAuMDAyICAgICAgICAgIDAuOTk4MzIwICAgIFxuUm91bmRRdWFydGVyZmluYWxzICAgICAgICAgICAgIC01LjI4OTE3MyAxMjc5LjUyNjQ1MCAgLTAuMDA0ICAgICAgICAgIDAuOTk2NzAyICAgIFxuUm91bmRSb3VuZCBSb2JpbiAgICAgICAgICAgICAgICA2LjYyNTY2NCAgICAyLjU3ODQ0OSAgIDIuNTcwICAgICAgICAgIDAuMDEwMTgxICogIFxuUm91bmRTZW1pZmluYWxzICAgICAgICAgICAgICAgICA3LjY0Mzk5NyAgICAyLjkzODM5OSAgIDIuNjAxICAgICAgICAgIDAuMDA5Mjg0ICoqIFxuUm91bmRUaGUgRmluYWwgICAgICAgICAgICAgICAgIDExLjMxNzk1OCAgICAyLjczMDcyNSAgIDQuMTQ1IDAuMDAwMDM0MDMwMDM4MzMwICoqKlxuQmVzdE9mNSAgICAgICAgICAgICAgICAgICAgICAgICAwLjQyNDEzMSAgICAwLjkyODg2NiAgIDAuNDU3ICAgICAgICAgIDAuNjQ3OTUwICAgIFxuUmFua05hZGFsICAgICAgICAgICAgICAgICAgICAgICAwLjEzMTE5NyAgICAwLjEyMjA2NSAgIDEuMDc1ICAgICAgICAgIDAuMjgyNDU4ICAgIFxuUmFua1JpdmFsICAgICAgICAgICAgICAgICAgICAgICAwLjAwODE5NyAgICAwLjAxMDAxNiAgIDAuODE4ICAgICAgICAgIDAuNDEzMTI3ICAgIFxuUGFydGlkb3NVbHQ2TWVzZXMgICAgICAgICAgICAgICAwLjA1NzYwMiAgICAwLjAzNDg0NCAgIDEuNjUzICAgICAgICAgIDAuMDk4MzAyIC4gIFxuUGFydGlkb3NVbHQzTWVzZXMgICAgICAgICAgICAgIC0wLjE0NzM5OCAgICAwLjA2NzY5MyAgLTIuMTc3ICAgICAgICAgIDAuMDI5NDQ3ICogIFxuUGFydGlkb3NVbHRNZXMgICAgICAgICAgICAgICAgIC0wLjM3NzIxMSAgICAwLjA5Nzc2NSAgLTMuODU4ICAgICAgICAgIDAuMDAwMTE0ICoqKlxuV1JVbHQ2TWVzZXMgICAgICAgICAgICAgICAgICAgLTEwLjExNDc5NSAgICA1LjQ3NjYzMCAgLTEuODQ3ICAgICAgICAgIDAuMDY0NzYxIC4gIFxuV1JVbHQzTWVzZXMgICAgICAgICAgICAgICAgICAgIDEwLjUzOTAxOSAgICA1LjY0NTk0MiAgIDEuODY3ICAgICAgICAgIDAuMDYxOTUwIC4gIFxuV1JVbHRNZXMgICAgICAgICAgICAgICAgICAgICAgIDI5LjU3MjMyNyAgICA0LjE0ODMwMiAgIDcuMTI5IDAuMDAwMDAwMDAwMDAxMDEzICoqKlxuUGFydGlkb3NSaXZhbFVsdDZNZXNlcyAgICAgICAgIC0wLjAyMDkwNyAgICAwLjA0NDI0MiAgLTAuNDczICAgICAgICAgIDAuNjM2NTMwICAgIFxuUGFydGlkb3NSaXZhbFVsdDNNZXNlcyAgICAgICAgICAwLjAyNjU3OSAgICAwLjA3MTYwMSAgIDAuMzcxICAgICAgICAgIDAuNzEwNDc4ICAgIFxuUGFydGlkb3NSaXZhbFVsdE1lcyAgICAgICAgICAgICAwLjI3ODQ3OCAgICAwLjEwMDA1NiAgIDIuNzgzICAgICAgICAgIDAuMDA1MzgyICoqIFxuV1JSaXZhbFVsdDZNZXNlcyAgICAgICAgICAgICAgICAyLjk5NzEzMCAgICA0LjI2OTgwMCAgIDAuNzAyICAgICAgICAgIDAuNDgyNzE5ICAgIFxuV1JSaXZhbFVsdDNNZXNlcyAgICAgICAgICAgICAgIC0xLjQxNTU2NCAgICA0LjE2Mjc1MyAgLTAuMzQwICAgICAgICAgIDAuNzMzODE1ICAgIFxuV1JSaXZhbFVsdE1lcyAgICAgICAgICAgICAgICAgLTI5LjcwMjE3NyAgICA0LjE0NDkxOSAgLTcuMTY2IDAuMDAwMDAwMDAwMDAwNzczICoqKlxuU2V0c0dhbmFkb3NVbHRQYXJ0aWRvICAgICAgICAgICAwLjkyOTQwMyAgICAwLjg2NDgwNCAgIDEuMDc1ICAgICAgICAgIDAuMjgyNTEwICAgIFxuU2V0c1BlcmRpZG9zVWx0UGFydGlkbyAgICAgICAgICAwLjA4ODUzNiAgICAwLjQwNjU3NSAgIDAuMjE4ICAgICAgICAgIDAuODI3NjE2ICAgIFxuUmVzdWx0VWx0UGFydGlkb1dpbiAgICAgICAgICAgIC02LjE3NjM0NyAgICAyLjU2ODA4OSAgLTIuNDA1ICAgICAgICAgIDAuMDE2MTcxICogIFxuUm91bmRVbHRQYXJ0aWRvMm5kIFJvdW5kICAgICAgIDEzLjAyNzU3NSAxMjc5LjUyNTUwOSAgIDAuMDEwICAgICAgICAgIDAuOTkxODc2ICAgIFxuUm91bmRVbHRQYXJ0aWRvM3JkIFJvdW5kICAgICAgIDEwLjMzODk2NSAxMjc5LjUyNjE3MSAgIDAuMDA4ICAgICAgICAgIDAuOTkzNTUzICAgIFxuUm91bmRVbHRQYXJ0aWRvNHRoIFJvdW5kICAgICAgIDEzLjA0Njk2MiAxMjc5LjUyNjEzNCAgIDAuMDEwICAgICAgICAgIDAuOTkxODY0ICAgIFxuUm91bmRVbHRQYXJ0aWRvUXVhcnRlcmZpbmFscyAgIC0xLjA3MjQ0NiAgICAyLjk2Mzk1NyAgLTAuMzYyICAgICAgICAgIDAuNzE3NDgwICAgIFxuUm91bmRVbHRQYXJ0aWRvUm91bmQgUm9iaW4gICAgICAxLjQ0MjIyMyAgICAyLjc0NTEyNCAgIDAuNTI1ICAgICAgICAgIDAuNTk5MzIyICAgIFxuUm91bmRVbHRQYXJ0aWRvU2VtaWZpbmFscyAgICAgIC00LjIyNjExOSAgICAyLjU2NDgyMCAgLTEuNjQ4ICAgICAgICAgIDAuMDk5NDA5IC4gIFxuUm91bmRVbHRQYXJ0aWRvVGhlIEZpbmFsICAgICAgIC0yLjgxODc4MiAgICAxLjQ1NTI5NCAgLTEuOTM3ICAgICAgICAgIDAuMDUyNzU2IC4gIFxuSDJIUGFydGlkb3MgICAgICAgICAgICAgICAgICAgICAwLjAxMTkzNSAgICAwLjA3OTI5OCAgIDAuMTUxICAgICAgICAgIDAuODgwMzYyICAgIFxuSDJIR2FuYWRvcyAgICAgICAgICAgICAgICAgICAgIC0wLjAyNjM3NSAgICAwLjEyNTA3NSAgLTAuMjExICAgICAgICAgIDAuODMyOTg1ICAgIFxuLS0tXG5TaWduaWYuIGNvZGVzOiAgMCDigJgqKirigJkgMC4wMDEg4oCYKirigJkgMC4wMSDigJgq4oCZIDAuMDUg4oCYLuKAmSAwLjEg4oCYIOKAmSAxXG5cbihEaXNwZXJzaW9uIHBhcmFtZXRlciBmb3IgYmlub21pYWwgZmFtaWx5IHRha2VuIHRvIGJlIDEpXG5cbiAgICBOdWxsIGRldmlhbmNlOiA4ODIuNDYgIG9uIDEwMDggIGRlZ3JlZXMgb2YgZnJlZWRvbVxuUmVzaWR1YWwgZGV2aWFuY2U6IDE5My41OSAgb24gIDk3MCAgZGVncmVlcyBvZiBmcmVlZG9tXG4gICgxNSBvYnNlcnZhdGlvbnMgZGVsZXRlZCBkdWUgdG8gbWlzc2luZ25lc3MpXG5BSUM6IDI3MS41OVxuXG5OdW1iZXIgb2YgRmlzaGVyIFNjb3JpbmcgaXRlcmF0aW9uczogMThcbiJ9 -->

```

Call:
glm(formula = Result ~ Court + Surface + Round + BestOf + RankNadal + 
    RankRival + PartidosUlt6Meses + PartidosUlt3Meses + PartidosUltMes + 
    WRUlt6Meses + WRUlt3Meses + WRUltMes + PartidosRivalUlt6Meses + 
    PartidosRivalUlt3Meses + PartidosRivalUltMes + WRRivalUlt6Meses + 
    WRRivalUlt3Meses + WRRivalUltMes + SetsGanadosUltPartido + 
    SetsPerdidosUltPartido + ResultUltPartido + RoundUltPartido + 
    H2HPartidos + H2HGanados, family = binomial(link = "logit"), 
    data = df_matches_train)

Deviance Residuals: 
     Min        1Q    Median        3Q       Max  
-3.13913   0.00035   0.01426   0.10526   2.89138  

Coefficients:
                                Estimate  Std. Error z value          Pr(>|z|)    
(Intercept)                    -3.447534    4.657520  -0.740          0.459174    
CourtOutdoor                    0.914366    0.871876   1.049          0.294301    
SurfaceClay                     1.628400    1.931914   0.843          0.399287    
SurfaceGrass                   -1.536851    2.075109  -0.741          0.458929    
SurfaceHard                    -0.835830    1.783118  -0.469          0.639251    
Round2nd Round                  3.919972    1.487815   2.635          0.008421 ** 
Round3rd Round                 -8.161199 1279.525715  -0.006          0.994911    
Round4th Round                 -2.693715 1279.527160  -0.002          0.998320    
RoundQuarterfinals             -5.289173 1279.526450  -0.004          0.996702    
RoundRound Robin                6.625664    2.578449   2.570          0.010181 *  
RoundSemifinals                 7.643997    2.938399   2.601          0.009284 ** 
RoundThe Final                 11.317958    2.730725   4.145 0.000034030038330 ***
BestOf5                         0.424131    0.928866   0.457          0.647950    
RankNadal                       0.131197    0.122065   1.075          0.282458    
RankRival                       0.008197    0.010016   0.818          0.413127    
PartidosUlt6Meses               0.057602    0.034844   1.653          0.098302 .  
PartidosUlt3Meses              -0.147398    0.067693  -2.177          0.029447 *  
PartidosUltMes                 -0.377211    0.097765  -3.858          0.000114 ***
WRUlt6Meses                   -10.114795    5.476630  -1.847          0.064761 .  
WRUlt3Meses                    10.539019    5.645942   1.867          0.061950 .  
WRUltMes                       29.572327    4.148302   7.129 0.000000000001013 ***
PartidosRivalUlt6Meses         -0.020907    0.044242  -0.473          0.636530    
PartidosRivalUlt3Meses          0.026579    0.071601   0.371          0.710478    
PartidosRivalUltMes             0.278478    0.100056   2.783          0.005382 ** 
WRRivalUlt6Meses                2.997130    4.269800   0.702          0.482719    
WRRivalUlt3Meses               -1.415564    4.162753  -0.340          0.733815    
WRRivalUltMes                 -29.702177    4.144919  -7.166 0.000000000000773 ***
SetsGanadosUltPartido           0.929403    0.864804   1.075          0.282510    
SetsPerdidosUltPartido          0.088536    0.406575   0.218          0.827616    
ResultUltPartidoWin            -6.176347    2.568089  -2.405          0.016171 *  
RoundUltPartido2nd Round       13.027575 1279.525509   0.010          0.991876    
RoundUltPartido3rd Round       10.338965 1279.526171   0.008          0.993553    
RoundUltPartido4th Round       13.046962 1279.526134   0.010          0.991864    
RoundUltPartidoQuarterfinals   -1.072446    2.963957  -0.362          0.717480    
RoundUltPartidoRound Robin      1.442223    2.745124   0.525          0.599322    
RoundUltPartidoSemifinals      -4.226119    2.564820  -1.648          0.099409 .  
RoundUltPartidoThe Final       -2.818782    1.455294  -1.937          0.052756 .  
H2HPartidos                     0.011935    0.079298   0.151          0.880362    
H2HGanados                     -0.026375    0.125075  -0.211          0.832985    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

(Dispersion parameter for binomial family taken to be 1)

    Null deviance: 882.46  on 1008  degrees of freedom
Residual deviance: 193.59  on  970  degrees of freedom
  (15 observations deleted due to missingness)
AIC: 271.59

Number of Fisher Scoring iterations: 18
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuI0RlIGFjw6Egc2UgZGVzcHJlbmRlIHF1ZSBlbCBXUiBlcyBpbXBvcnRhbnRlLiBTdXJmYWNlIHRhbWJpZW4uIEgySCBubyBwYXJlY2VcbiBcblxuYGBgIn0= -->

```r
#De acá se desprende que el WR es importante. Surface tambien. H2H no parece
 

```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->



Luego de este primer analisis, las variables que vamos a retener son:

- Surface (si bien tiene p valor bajo, puede deberse a correlacion con otra covariable)
- BestOf
- Round
- Rank Nadal
- Rank Rival
- Partidos Ult 6 / 3 / mes
- WR 6 / 3 / mes
- Partidos Rival Ult 6 / 3 / mes
- WR Rival 6 / 3 / mes
- ResultUltPartido
- H2HPartidos
- H2H Ganados

Estas variables van a ser combinadas de varias formas, buscando el mejor modelo.



<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuXG4jTW9kZWxvIDIgXG5cbmdsbS5maXQyIDwtIGdsbShSZXN1bHQgfiBSYW5rTmFkYWwgKyBSYW5rUml2YWwgKyBTdXJmYWNlICtcbiAgICAgICAgICAgICAgICBXUlVsdDNNZXNlcyArIFdSUml2YWxVbHQzTWVzZXMgKyBXUlVsdE1lcyArIFxuICAgICAgICAgICAgICAgIFdSUml2YWxVbHRNZXMgKyBQYXJ0aWRvc1VsdE1lcyArIFBhcnRpZG9zUml2YWxVbHRNZXMgK1xuICAgICAgICAgICAgICAgIFJvdW5kICsgQmVzdE9mLFxuICAgICAgICAgICAgICAgZGF0YSA9IGRmX21hdGNoZXNfdHJhaW4sXG4gICAgICAgICAgICAgICBmYW1pbHkgPSBiaW5vbWlhbChsaW5rID0gXCJsb2dpdFwiKSlcblxuc3VtbWFyeShnbG0uZml0MilcbmBgYCJ9 -->

```r

#Modelo 2 

glm.fit2 <- glm(Result ~ RankNadal + RankRival + Surface +
                WRUlt3Meses + WRRivalUlt3Meses + WRUltMes + 
                WRRivalUltMes + PartidosUltMes + PartidosRivalUltMes +
                Round + BestOf,
               data = df_matches_train,
               family = binomial(link = "logit"))

summary(glm.fit2)
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiXG5DYWxsOlxuZ2xtKGZvcm11bGEgPSBSZXN1bHQgfiBSYW5rTmFkYWwgKyBSYW5rUml2YWwgKyBTdXJmYWNlICsgV1JVbHQzTWVzZXMgKyBcbiAgICBXUlJpdmFsVWx0M01lc2VzICsgV1JVbHRNZXMgKyBXUlJpdmFsVWx0TWVzICsgUGFydGlkb3NVbHRNZXMgKyBcbiAgICBQYXJ0aWRvc1JpdmFsVWx0TWVzICsgUm91bmQgKyBCZXN0T2YsIGZhbWlseSA9IGJpbm9taWFsKGxpbmsgPSBcImxvZ2l0XCIpLCBcbiAgICBkYXRhID0gZGZfbWF0Y2hlc190cmFpbilcblxuRGV2aWFuY2UgUmVzaWR1YWxzOiBcbiAgICBNaW4gICAgICAgMVEgICBNZWRpYW4gICAgICAgM1EgICAgICBNYXggIFxuLTMuNjQ1NCAgIDAuMDAyNiAgIDAuMDMxOSAgIDAuMTQ0NCAgIDIuNjA4OCAgXG5cbkNvZWZmaWNpZW50czpcbiAgICAgICAgICAgICAgICAgICAgICBFc3RpbWF0ZSBTdGQuIEVycm9yIHogdmFsdWUgICAgICAgICAgICAgUHIoPnx6fCkgICAgXG4oSW50ZXJjZXB0KSAgICAgICAgICAtNi4wMDI4MDkgICAzLjAwMzQ4NiAgLTEuOTk5ICAgICAgICAgICAgIDAuMDQ1NjUwICogIFxuUmFua05hZGFsICAgICAgICAgICAgIDAuMDgyOTc3ICAgMC4wOTA5NTEgICAwLjkxMiAgICAgICAgICAgICAwLjM2MTU5OSAgICBcblJhbmtSaXZhbCAgICAgICAgICAgICAwLjAwNTAzOCAgIDAuMDA3NTMwICAgMC42NjkgICAgICAgICAgICAgMC41MDM1MTEgICAgXG5TdXJmYWNlQ2xheSAgICAgICAgICAgMi44NDMyMTQgICAxLjM5Nzk3OCAgIDIuMDM0ICAgICAgICAgICAgIDAuMDQxOTcxICogIFxuU3VyZmFjZUdyYXNzICAgICAgICAgLTAuMzk3MDU3ICAgMS41MDcwMDUgIC0wLjI2MyAgICAgICAgICAgICAwLjc5MjE4NSAgICBcblN1cmZhY2VIYXJkICAgICAgICAgICAxLjIyODkzMiAgIDEuMzQ4MTExICAgMC45MTIgICAgICAgICAgICAgMC4zNjE5ODEgICAgXG5XUlVsdDNNZXNlcyAgICAgICAgICAtMC45NDY4NzYgICAzLjE0NTYzOSAgLTAuMzAxICAgICAgICAgICAgIDAuNzYzNDA1ICAgIFxuV1JSaXZhbFVsdDNNZXNlcyAgICAgLTAuMjI2NzA4ICAgMi4xODMzOTEgIC0wLjEwNCAgICAgICAgICAgICAwLjkxNzMwMiAgICBcbldSVWx0TWVzICAgICAgICAgICAgIDI0LjkwOTg1NSAgIDIuOTk3NDIxICAgOC4zMTAgPCAwLjAwMDAwMDAwMDAwMDAwMDIgKioqXG5XUlJpdmFsVWx0TWVzICAgICAgIC0yNC4zMTEzMDIgICAzLjA1OTk1MiAgLTcuOTQ1ICAwLjAwMDAwMDAwMDAwMDAwMTk0ICoqKlxuUGFydGlkb3NVbHRNZXMgICAgICAgLTAuMzk0MTM1ICAgMC4wNzYwODIgIC01LjE4MCAgMC4wMDAwMDAyMjE0MzA2MjA1MiAqKipcblBhcnRpZG9zUml2YWxVbHRNZXMgICAwLjIzMjMyOCAgIDAuMDY5OTUwICAgMy4zMjEgICAgICAgICAgICAgMC4wMDA4OTYgKioqXG5Sb3VuZDJuZCBSb3VuZCAgICAgICAgMy43MjU3MzYgICAwLjk3MDA3NSAgIDMuODQxICAgICAgICAgICAgIDAuMDAwMTIzICoqKlxuUm91bmQzcmQgUm91bmQgICAgICAgIDQuMjQ5MjA4ICAgMC45ODQ3NzUgICA0LjMxNSAgMC4wMDAwMTU5NjczMTU2NTg2NyAqKipcblJvdW5kNHRoIFJvdW5kICAgICAgICA2LjE5MjY1OCAgIDEuMjQ2OTcwICAgNC45NjYgIDAuMDAwMDAwNjgyOTAxNTY1MTIgKioqXG5Sb3VuZFF1YXJ0ZXJmaW5hbHMgICAgNS4zODQ4NzUgICAxLjA4NzY0MyAgIDQuOTUxICAwLjAwMDAwMDczODQ5MjQzMTk4ICoqKlxuUm91bmRSb3VuZCBSb2JpbiAgICAgIDUuMzA0OTU5ICAgMS4zNzUwMzcgICAzLjg1OCAgICAgICAgICAgICAwLjAwMDExNCAqKipcblJvdW5kU2VtaWZpbmFscyAgICAgICA1LjQwMjg5OSAgIDEuMTIyMDgzICAgNC44MTUgIDAuMDAwMDAxNDcxNTQ3MTM2NTcgKioqXG5Sb3VuZFRoZSBGaW5hbCAgICAgICAgNi4wNDgyNjAgICAxLjI2NDY1OCAgIDQuNzgzICAwLjAwMDAwMTczMTA0NjM0NjI5ICoqKlxuQmVzdE9mNSAgICAgICAgICAgICAgIDEuNjQ3ODE0ICAgMC40NDcwODkgICAzLjY4NiAgICAgICAgICAgICAwLjAwMDIyOCAqKipcbi0tLVxuU2lnbmlmLiBjb2RlczogIDAg4oCYKioq4oCZIDAuMDAxIOKAmCoq4oCZIDAuMDEg4oCYKuKAmSAwLjA1IOKAmC7igJkgMC4xIOKAmCDigJkgMVxuXG4oRGlzcGVyc2lvbiBwYXJhbWV0ZXIgZm9yIGJpbm9taWFsIGZhbWlseSB0YWtlbiB0byBiZSAxKVxuXG4gICAgTnVsbCBkZXZpYW5jZTogOTAwLjk3ICBvbiAxMDIzICBkZWdyZWVzIG9mIGZyZWVkb21cblJlc2lkdWFsIGRldmlhbmNlOiAyNDMuMzAgIG9uIDEwMDQgIGRlZ3JlZXMgb2YgZnJlZWRvbVxuQUlDOiAyODMuM1xuXG5OdW1iZXIgb2YgRmlzaGVyIFNjb3JpbmcgaXRlcmF0aW9uczogOFxuIn0= -->

```

Call:
glm(formula = Result ~ RankNadal + RankRival + Surface + WRUlt3Meses + 
    WRRivalUlt3Meses + WRUltMes + WRRivalUltMes + PartidosUltMes + 
    PartidosRivalUltMes + Round + BestOf, family = binomial(link = "logit"), 
    data = df_matches_train)

Deviance Residuals: 
    Min       1Q   Median       3Q      Max  
-3.6454   0.0026   0.0319   0.1444   2.6088  

Coefficients:
                      Estimate Std. Error z value             Pr(>|z|)    
(Intercept)          -6.002809   3.003486  -1.999             0.045650 *  
RankNadal             0.082977   0.090951   0.912             0.361599    
RankRival             0.005038   0.007530   0.669             0.503511    
SurfaceClay           2.843214   1.397978   2.034             0.041971 *  
SurfaceGrass         -0.397057   1.507005  -0.263             0.792185    
SurfaceHard           1.228932   1.348111   0.912             0.361981    
WRUlt3Meses          -0.946876   3.145639  -0.301             0.763405    
WRRivalUlt3Meses     -0.226708   2.183391  -0.104             0.917302    
WRUltMes             24.909855   2.997421   8.310 < 0.0000000000000002 ***
WRRivalUltMes       -24.311302   3.059952  -7.945  0.00000000000000194 ***
PartidosUltMes       -0.394135   0.076082  -5.180  0.00000022143062052 ***
PartidosRivalUltMes   0.232328   0.069950   3.321             0.000896 ***
Round2nd Round        3.725736   0.970075   3.841             0.000123 ***
Round3rd Round        4.249208   0.984775   4.315  0.00001596731565867 ***
Round4th Round        6.192658   1.246970   4.966  0.00000068290156512 ***
RoundQuarterfinals    5.384875   1.087643   4.951  0.00000073849243198 ***
RoundRound Robin      5.304959   1.375037   3.858             0.000114 ***
RoundSemifinals       5.402899   1.122083   4.815  0.00000147154713657 ***
RoundThe Final        6.048260   1.264658   4.783  0.00000173104634629 ***
BestOf5               1.647814   0.447089   3.686             0.000228 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

(Dispersion parameter for binomial family taken to be 1)

    Null deviance: 900.97  on 1023  degrees of freedom
Residual deviance: 243.30  on 1004  degrees of freedom
AIC: 283.3

Number of Fisher Scoring iterations: 8
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuI1dSIGVzIG11eSBpbXBvcnRhbnRlLiBQYXJ0aWRvcyBqdWdhZG9zIHRhbWJpZW4uIFJvdW5kIHkgU3VyZmFjZSB0YW1iaWVuLlxuI1JhbmsgbcOhcyBvIG1lbm9zLlxuXG5nbG0ucHJvYnMyIDwtIHByZWRpY3QoZ2xtLmZpdDIsIGRmX21hdGNoZXNfdGVzdCxcbiAgICAgICAgICAgICAgICAgICAgIHR5cGUgPSBcInJlc3BvbnNlXCIpXG5cbmNvbnRyYXN0cyhkZl9tYXRjaGVzX3RyYWluJFJlc3VsdClcbmBgYCJ9 -->

```r
#WR es muy importante. Partidos jugados tambien. Round y Surface tambien.
#Rank más o menos.

glm.probs2 <- predict(glm.fit2, df_matches_test,
                     type = "response")

contrasts(df_matches_train$Result)
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiICAgICBXaW5cbkxvc2UgICAwXG5XaW4gICAgMVxuIn0= -->

```
     Win
Lose   0
Win    1
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuZ2xtLnByZWQyIDwtIHJlcChcIkxvc2VcIiwgbnJvdyhkZl9tYXRjaGVzX3Rlc3QpKVxuZ2xtLnByZWQyW2dsbS5wcm9iczIgPiAwLjU1XSA9IFwiV2luXCJcblxudGFibGUoZ2xtLnByZWQyLCBSZWFsID0gZGZfbWF0Y2hlc190ZXN0JFJlc3VsdClcbmBgYCJ9 -->

```r
glm.pred2 <- rep("Lose", nrow(df_matches_test))
glm.pred2[glm.probs2 > 0.55] = "Win"

table(glm.pred2, Real = df_matches_test$Result)
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiICAgICAgICAgUmVhbFxuZ2xtLnByZWQyIExvc2UgV2luXG4gICAgIExvc2UgICAgNiAgIDFcbiAgICAgV2luICAgICAyICA0MFxuIn0= -->

```
         Real
glm.pred2 Lose Win
     Lose    6   1
     Win     2  40
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuIyBNb2RlbG8gMyA9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT1cblxuI1ZveSBhIGRlamFyIHNvbG8gdWx0aW1vcyAzIHkgdWx0aW1vcyA2IG1lc2VzXG5cbmdsbS5maXQzIDwtIGdsbShSZXN1bHQgfiBTdXJmYWNlICsgV1JVbHQzTWVzZXMgKyBXUlJpdmFsVWx0M01lc2VzICtcbiAgICAgICAgICAgICAgICAgIFBhcnRpZG9zVWx0M01lc2VzICsgUGFydGlkb3NSaXZhbFVsdDNNZXNlcyArIFdSVWx0TWVzICsgXG4gICAgICAgICAgICAgICAgICBXUlJpdmFsVWx0TWVzICsgUGFydGlkb3NVbHRNZXMgKyBQYXJ0aWRvc1JpdmFsVWx0TWVzICtcbiAgICAgICAgICAgICAgICAgIFdSVWx0Nk1lc2VzICsgV1JSaXZhbFVsdDZNZXNlcyArIFBhcnRpZG9zVWx0Nk1lc2VzICtcbiAgICAgICAgICAgICAgICAgIFBhcnRpZG9zUml2YWxVbHQ2TWVzZXMgKyBSb3VuZCArIEJlc3RPZixcbiAgICAgICAgICAgICAgICBkYXRhID0gZGZfbWF0Y2hlc190cmFpbixcbiAgICAgICAgICAgICAgICBmYW1pbHkgPSBiaW5vbWlhbClcblxuc3VtbWFyeShnbG0uZml0MylcbmBgYCJ9 -->

```r
# Modelo 3 ======================================================

#Voy a dejar solo ultimos 3 y ultimos 6 meses

glm.fit3 <- glm(Result ~ Surface + WRUlt3Meses + WRRivalUlt3Meses +
                  PartidosUlt3Meses + PartidosRivalUlt3Meses + WRUltMes + 
                  WRRivalUltMes + PartidosUltMes + PartidosRivalUltMes +
                  WRUlt6Meses + WRRivalUlt6Meses + PartidosUlt6Meses +
                  PartidosRivalUlt6Meses + Round + BestOf,
                data = df_matches_train,
                family = binomial)

summary(glm.fit3)
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiXG5DYWxsOlxuZ2xtKGZvcm11bGEgPSBSZXN1bHQgfiBTdXJmYWNlICsgV1JVbHQzTWVzZXMgKyBXUlJpdmFsVWx0M01lc2VzICsgXG4gICAgUGFydGlkb3NVbHQzTWVzZXMgKyBQYXJ0aWRvc1JpdmFsVWx0M01lc2VzICsgV1JVbHRNZXMgKyBXUlJpdmFsVWx0TWVzICsgXG4gICAgUGFydGlkb3NVbHRNZXMgKyBQYXJ0aWRvc1JpdmFsVWx0TWVzICsgV1JVbHQ2TWVzZXMgKyBXUlJpdmFsVWx0Nk1lc2VzICsgXG4gICAgUGFydGlkb3NVbHQ2TWVzZXMgKyBQYXJ0aWRvc1JpdmFsVWx0Nk1lc2VzICsgUm91bmQgKyBCZXN0T2YsIFxuICAgIGZhbWlseSA9IGJpbm9taWFsLCBkYXRhID0gZGZfbWF0Y2hlc190cmFpbilcblxuRGV2aWFuY2UgUmVzaWR1YWxzOiBcbiAgICBNaW4gICAgICAgMVEgICBNZWRpYW4gICAgICAgM1EgICAgICBNYXggIFxuLTMuNTY2OCAgIDAuMDAxOSAgIDAuMDMwNiAgIDAuMTQ0NCAgIDIuNjIxMSAgXG5cbkNvZWZmaWNpZW50czpcbiAgICAgICAgICAgICAgICAgICAgICAgIEVzdGltYXRlIFN0ZC4gRXJyb3IgeiB2YWx1ZSAgICAgICAgICAgIFByKD58enwpICAgIFxuKEludGVyY2VwdCkgICAgICAgICAgICAgLTEuNjEyOTEgICAgMi45ODg2MyAgLTAuNTQwICAgICAgICAgICAgMC41ODk0MTYgICAgXG5TdXJmYWNlQ2xheSAgICAgICAgICAgICAgMi4wNTM1MCAgICAxLjU0OTQ2ICAgMS4zMjUgICAgICAgICAgICAwLjE4NTA3MSAgICBcblN1cmZhY2VHcmFzcyAgICAgICAgICAgIC0wLjY0ODI0ICAgIDEuNjY0MTQgIC0wLjM5MCAgICAgICAgICAgIDAuNjk2ODgwICAgIFxuU3VyZmFjZUhhcmQgICAgICAgICAgICAgIDAuMzYzMDcgICAgMS40MzU3MCAgIDAuMjUzICAgICAgICAgICAgMC44MDAzNTggICAgXG5XUlVsdDNNZXNlcyAgICAgICAgICAgICAgOS43NjA3OCAgICA1LjA3OTY5ICAgMS45MjIgICAgICAgICAgICAwLjA1NDY2NSAuICBcbldSUml2YWxVbHQzTWVzZXMgICAgICAgIC0zLjE1MzUzICAgIDMuNDA3NDQgIC0wLjkyNSAgICAgICAgICAgIDAuMzU0NzE2ICAgIFxuUGFydGlkb3NVbHQzTWVzZXMgICAgICAgLTAuMTAzNjggICAgMC4wNTc5MSAgLTEuNzkxICAgICAgICAgICAgMC4wNzMzNjcgLiAgXG5QYXJ0aWRvc1JpdmFsVWx0M01lc2VzICAgMC4wNjE1NSAgICAwLjA1NjY4ICAgMS4wODYgICAgICAgICAgICAwLjI3NzU4MyAgICBcbldSVWx0TWVzICAgICAgICAgICAgICAgIDIzLjg2MzI4ICAgIDMuMDUyNTAgICA3LjgxOCAwLjAwMDAwMDAwMDAwMDAwNTM4ICoqKlxuV1JSaXZhbFVsdE1lcyAgICAgICAgICAtMjQuNDg5MjIgICAgMy4wODEwMyAgLTcuOTQ4IDAuMDAwMDAwMDAwMDAwMDAxODkgKioqXG5QYXJ0aWRvc1VsdE1lcyAgICAgICAgICAtMC4zNTAxOSAgICAwLjA4NTIyICAtNC4xMDkgMC4wMDAwMzk3MTEyOTQ1NjI5MyAqKipcblBhcnRpZG9zUml2YWxVbHRNZXMgICAgICAwLjE5NjE5ICAgIDAuMDg0OTIgICAyLjMxMCAgICAgICAgICAgIDAuMDIwODczICogIFxuV1JVbHQ2TWVzZXMgICAgICAgICAgICAtMTIuMDQ3MzggICAgNC42NjA0OSAgLTIuNTg1ICAgICAgICAgICAgMC4wMDk3MzggKiogXG5XUlJpdmFsVWx0Nk1lc2VzICAgICAgICAgMi41MjA1NiAgICAzLjM0MTUyICAgMC43NTQgICAgICAgICAgICAwLjQ1MDY2MCAgICBcblBhcnRpZG9zVWx0Nk1lc2VzICAgICAgICAwLjAzOTE2ICAgIDAuMDI5MzkgICAxLjMzMyAgICAgICAgICAgIDAuMTgyNjE1ICAgIFxuUGFydGlkb3NSaXZhbFVsdDZNZXNlcyAgLTAuMDM3NDMgICAgMC4wMzQzNSAgLTEuMDkwICAgICAgICAgICAgMC4yNzU4MTIgICAgXG5Sb3VuZDJuZCBSb3VuZCAgICAgICAgICAgMy42MjczNyAgICAwLjk4Mzk1ICAgMy42ODcgICAgICAgICAgICAwLjAwMDIyNyAqKipcblJvdW5kM3JkIFJvdW5kICAgICAgICAgICA0LjAxNjY4ICAgIDAuOTk2ODEgICA0LjAzMCAwLjAwMDA1NTg4OTQyODM3NzE2ICoqKlxuUm91bmQ0dGggUm91bmQgICAgICAgICAgIDUuOTczMzEgICAgMS4yODMyOCAgIDQuNjU1IDAuMDAwMDAzMjQ0NDc3NjQzNzMgKioqXG5Sb3VuZFF1YXJ0ZXJmaW5hbHMgICAgICAgNS4xODcwNiAgICAxLjEwNTA5ICAgNC42OTQgMC4wMDAwMDI2ODE2NTMzNTE5NiAqKipcblJvdW5kUm91bmQgUm9iaW4gICAgICAgICA1LjMwOTIxICAgIDEuNDA3NzggICAzLjc3MSAgICAgICAgICAgIDAuMDAwMTYyICoqKlxuUm91bmRTZW1pZmluYWxzICAgICAgICAgIDUuMjkwMjYgICAgMS4xNTAwOSAgIDQuNjAwIDAuMDAwMDA0MjI3NzM4ODYzMjcgKioqXG5Sb3VuZFRoZSBGaW5hbCAgICAgICAgICAgNS45OTU2MSAgICAxLjMwMjUwICAgNC42MDMgMC4wMDAwMDQxNjEwNzczMDE2NyAqKipcbkJlc3RPZjUgICAgICAgICAgICAgICAgICAxLjYwNDgyICAgIDAuNDc5NjIgICAzLjM0NiAgICAgICAgICAgIDAuMDAwODIwICoqKlxuLS0tXG5TaWduaWYuIGNvZGVzOiAgMCDigJgqKirigJkgMC4wMDEg4oCYKirigJkgMC4wMSDigJgq4oCZIDAuMDUg4oCYLuKAmSAwLjEg4oCYIOKAmSAxXG5cbihEaXNwZXJzaW9uIHBhcmFtZXRlciBmb3IgYmlub21pYWwgZmFtaWx5IHRha2VuIHRvIGJlIDEpXG5cbiAgICBOdWxsIGRldmlhbmNlOiA5MDAuOTcgIG9uIDEwMjMgIGRlZ3JlZXMgb2YgZnJlZWRvbVxuUmVzaWR1YWwgZGV2aWFuY2U6IDIzNS4yMSAgb24gMTAwMCAgZGVncmVlcyBvZiBmcmVlZG9tXG5BSUM6IDI4My4yMVxuXG5OdW1iZXIgb2YgRmlzaGVyIFNjb3JpbmcgaXRlcmF0aW9uczogOFxuIn0= -->

```

Call:
glm(formula = Result ~ Surface + WRUlt3Meses + WRRivalUlt3Meses + 
    PartidosUlt3Meses + PartidosRivalUlt3Meses + WRUltMes + WRRivalUltMes + 
    PartidosUltMes + PartidosRivalUltMes + WRUlt6Meses + WRRivalUlt6Meses + 
    PartidosUlt6Meses + PartidosRivalUlt6Meses + Round + BestOf, 
    family = binomial, data = df_matches_train)

Deviance Residuals: 
    Min       1Q   Median       3Q      Max  
-3.5668   0.0019   0.0306   0.1444   2.6211  

Coefficients:
                        Estimate Std. Error z value            Pr(>|z|)    
(Intercept)             -1.61291    2.98863  -0.540            0.589416    
SurfaceClay              2.05350    1.54946   1.325            0.185071    
SurfaceGrass            -0.64824    1.66414  -0.390            0.696880    
SurfaceHard              0.36307    1.43570   0.253            0.800358    
WRUlt3Meses              9.76078    5.07969   1.922            0.054665 .  
WRRivalUlt3Meses        -3.15353    3.40744  -0.925            0.354716    
PartidosUlt3Meses       -0.10368    0.05791  -1.791            0.073367 .  
PartidosRivalUlt3Meses   0.06155    0.05668   1.086            0.277583    
WRUltMes                23.86328    3.05250   7.818 0.00000000000000538 ***
WRRivalUltMes          -24.48922    3.08103  -7.948 0.00000000000000189 ***
PartidosUltMes          -0.35019    0.08522  -4.109 0.00003971129456293 ***
PartidosRivalUltMes      0.19619    0.08492   2.310            0.020873 *  
WRUlt6Meses            -12.04738    4.66049  -2.585            0.009738 ** 
WRRivalUlt6Meses         2.52056    3.34152   0.754            0.450660    
PartidosUlt6Meses        0.03916    0.02939   1.333            0.182615    
PartidosRivalUlt6Meses  -0.03743    0.03435  -1.090            0.275812    
Round2nd Round           3.62737    0.98395   3.687            0.000227 ***
Round3rd Round           4.01668    0.99681   4.030 0.00005588942837716 ***
Round4th Round           5.97331    1.28328   4.655 0.00000324447764373 ***
RoundQuarterfinals       5.18706    1.10509   4.694 0.00000268165335196 ***
RoundRound Robin         5.30921    1.40778   3.771            0.000162 ***
RoundSemifinals          5.29026    1.15009   4.600 0.00000422773886327 ***
RoundThe Final           5.99561    1.30250   4.603 0.00000416107730167 ***
BestOf5                  1.60482    0.47962   3.346            0.000820 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

(Dispersion parameter for binomial family taken to be 1)

    Null deviance: 900.97  on 1023  degrees of freedom
Residual deviance: 235.21  on 1000  degrees of freedom
AIC: 283.21

Number of Fisher Scoring iterations: 8
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuZ2xtLnByb2JzMyA8LSBwcmVkaWN0KGdsbS5maXQzLCBkZl9tYXRjaGVzX3Rlc3QsXG4gICAgICAgICAgICAgICAgICAgICAgdHlwZSA9IFwicmVzcG9uc2VcIilcblxuZ2xtLnByZWQzIDwtIHJlcChcIkxvc2VcIiwgbnJvdyhkZl9tYXRjaGVzX3Rlc3QpKVxuZ2xtLnByZWQzW2dsbS5wcm9iczMgPiAwLjU1XSA9IFwiV2luXCJcblxudGFibGUoZ2xtLnByZWQzLCBkZl9tYXRjaGVzX3Rlc3QkUmVzdWx0KVxuYGBgIn0= -->

```r
glm.probs3 <- predict(glm.fit3, df_matches_test,
                      type = "response")

glm.pred3 <- rep("Lose", nrow(df_matches_test))
glm.pred3[glm.probs3 > 0.55] = "Win"

table(glm.pred3, df_matches_test$Result)
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiICAgICAgICAgXG5nbG0ucHJlZDMgTG9zZSBXaW5cbiAgICAgTG9zZSAgICA1ICAgMFxuICAgICBXaW4gICAgIDMgIDQxXG4ifQ== -->

```
         
glm.pred3 Lose Win
     Lose    5   0
     Win     3  41
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuIyBNb2RlbG8gNCA9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PVxuIyBBaG9yYSBqdW50byB0b2RhcyBsYXMgdmFyaWFibGVzIHF1ZSBtZSBkaWVyb24gcmVzdWx0YWRvXG5cbmdsbS5maXQ0IDwtIGdsbShSZXN1bHQgfiAgU3VyZmFjZSArIFdSVWx0M01lc2VzICsgV1JSaXZhbFVsdDNNZXNlcyArXG4gICAgICAgICAgICAgICAgICBQYXJ0aWRvc1VsdDNNZXNlcyArIFBhcnRpZG9zUml2YWxVbHQzTWVzZXMgKyBXUlVsdE1lcyArIFxuICAgICAgICAgICAgICAgICAgV1JSaXZhbFVsdE1lcyArIFBhcnRpZG9zVWx0TWVzICsgUGFydGlkb3NSaXZhbFVsdE1lcyArXG4gICAgICAgICAgICAgICAgICBSb3VuZCArIEJlc3RPZiArIFJhbmtOYWRhbCArIFJhbmtSaXZhbCxcbiAgICAgICAgICAgICAgICBkYXRhID0gZGZfbWF0Y2hlc190cmFpbixcbiAgICAgICAgICAgICAgICBmYW1pbHkgPSBiaW5vbWlhbClcblxuc3VtbWFyeShnbG0uZml0NClcbmBgYCJ9 -->

```r
# Modelo 4 =====================================================
# Ahora junto todas las variables que me dieron resultado

glm.fit4 <- glm(Result ~  Surface + WRUlt3Meses + WRRivalUlt3Meses +
                  PartidosUlt3Meses + PartidosRivalUlt3Meses + WRUltMes + 
                  WRRivalUltMes + PartidosUltMes + PartidosRivalUltMes +
                  Round + BestOf + RankNadal + RankRival,
                data = df_matches_train,
                family = binomial)

summary(glm.fit4)
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiXG5DYWxsOlxuZ2xtKGZvcm11bGEgPSBSZXN1bHQgfiBTdXJmYWNlICsgV1JVbHQzTWVzZXMgKyBXUlJpdmFsVWx0M01lc2VzICsgXG4gICAgUGFydGlkb3NVbHQzTWVzZXMgKyBQYXJ0aWRvc1JpdmFsVWx0M01lc2VzICsgV1JVbHRNZXMgKyBXUlJpdmFsVWx0TWVzICsgXG4gICAgUGFydGlkb3NVbHRNZXMgKyBQYXJ0aWRvc1JpdmFsVWx0TWVzICsgUm91bmQgKyBCZXN0T2YgKyBSYW5rTmFkYWwgKyBcbiAgICBSYW5rUml2YWwsIGZhbWlseSA9IGJpbm9taWFsLCBkYXRhID0gZGZfbWF0Y2hlc190cmFpbilcblxuRGV2aWFuY2UgUmVzaWR1YWxzOiBcbiAgICBNaW4gICAgICAgMVEgICBNZWRpYW4gICAgICAgM1EgICAgICBNYXggIFxuLTMuNjgyNSAgIDAuMDAyNCAgIDAuMDMxNiAgIDAuMTUxNCAgIDIuNjUyNyAgXG5cbkNvZWZmaWNpZW50czpcbiAgICAgICAgICAgICAgICAgICAgICAgICBFc3RpbWF0ZSBTdGQuIEVycm9yIHogdmFsdWUgICAgICAgICAgICAgUHIoPnx6fCkgICAgXG4oSW50ZXJjZXB0KSAgICAgICAgICAgICAtNi40NTI2MjYgICAzLjA1ODY0NSAgLTIuMTEwICAgICAgICAgICAgIDAuMDM0ODkwICogIFxuU3VyZmFjZUNsYXkgICAgICAgICAgICAgIDIuODI0NDU3ICAgMS40MzI3MDQgICAxLjk3MSAgICAgICAgICAgICAwLjA0ODY3NiAqICBcblN1cmZhY2VHcmFzcyAgICAgICAgICAgIC0wLjA0Njg5MyAgIDEuNTg3OTU4ICAtMC4wMzAgICAgICAgICAgICAgMC45NzY0NDEgICAgXG5TdXJmYWNlSGFyZCAgICAgICAgICAgICAgMS4xNTYxODYgICAxLjM4MDA1OSAgIDAuODM4ICAgICAgICAgICAgIDAuNDAyMTU0ICAgIFxuV1JVbHQzTWVzZXMgICAgICAgICAgICAgIDAuNDU0Nzk4ICAgMy41MDU0OTIgICAwLjEzMCAgICAgICAgICAgICAwLjg5Njc3MyAgICBcbldSUml2YWxVbHQzTWVzZXMgICAgICAgIC0wLjcyNzIzMiAgIDIuMzA2NjMzICAtMC4zMTUgICAgICAgICAgICAgMC43NTI1NTAgICAgXG5QYXJ0aWRvc1VsdDNNZXNlcyAgICAgICAtMC4wNDM0ODggICAwLjAzOTg4MiAgLTEuMDkwICAgICAgICAgICAgIDAuMjc1NTMwICAgIFxuUGFydGlkb3NSaXZhbFVsdDNNZXNlcyAgIDAuMDI3ODgxICAgMC4wNDUzOTcgICAwLjYxNCAgICAgICAgICAgICAwLjUzOTEwMCAgICBcbldSVWx0TWVzICAgICAgICAgICAgICAgIDI0LjU4MTAxMiAgIDMuMDMyNDY2ICAgOC4xMDYgMC4wMDAwMDAwMDAwMDAwMDA1MjMgKioqXG5XUlJpdmFsVWx0TWVzICAgICAgICAgIC0yNC4xNTMyOTYgICAzLjA4MDk5NCAgLTcuODM5IDAuMDAwMDAwMDAwMDAwMDA0NTI1ICoqKlxuUGFydGlkb3NVbHRNZXMgICAgICAgICAgLTAuMzU0MzkwICAgMC4wODQ3OTEgIC00LjE4MCAwLjAwMDAyOTIwNTM5NDEyNzc0MSAqKipcblBhcnRpZG9zUml2YWxVbHRNZXMgICAgICAwLjIxMzcyNCAgIDAuMDgyNTYwICAgMi41ODkgICAgICAgICAgICAgMC4wMDk2MzQgKiogXG5Sb3VuZDJuZCBSb3VuZCAgICAgICAgICAgMy42ODQyMzIgICAwLjk2OTU1NyAgIDMuODAwICAgICAgICAgICAgIDAuMDAwMTQ1ICoqKlxuUm91bmQzcmQgUm91bmQgICAgICAgICAgIDQuMjU3Nzc1ICAgMC45ODI1NjEgICA0LjMzMyAwLjAwMDAxNDY4NjAxMjk3Mzg4NCAqKipcblJvdW5kNHRoIFJvdW5kICAgICAgICAgICA2LjE5OTUxMCAgIDEuMjQ5OTIxICAgNC45NjAgMC4wMDAwMDA3MDUyMjA1MjUxODQgKioqXG5Sb3VuZFF1YXJ0ZXJmaW5hbHMgICAgICAgNS4zNjE0NzAgICAxLjA5MjUzOSAgIDQuOTA3IDAuMDAwMDAwOTIzMTU1NDM0MDc3ICoqKlxuUm91bmRSb3VuZCBSb2JpbiAgICAgICAgIDUuMjA3MDU0ICAgMS4zNzQ4MTAgICAzLjc4NyAgICAgICAgICAgICAwLjAwMDE1MiAqKipcblJvdW5kU2VtaWZpbmFscyAgICAgICAgICA1LjM3NjU4NyAgIDEuMTI0ODU1ICAgNC43ODAgMC4wMDAwMDE3NTQ2NTczNDI4OTYgKioqXG5Sb3VuZFRoZSBGaW5hbCAgICAgICAgICAgNS45NTg1OTAgICAxLjI3MDM3NiAgIDQuNjkwIDAuMDAwMDAyNzI2NTQyNzQyNzYzICoqKlxuQmVzdE9mNSAgICAgICAgICAgICAgICAgIDEuNjIzNDE5ICAgMC40NTQ5MTEgICAzLjU2OSAgICAgICAgICAgICAwLjAwMDM1OSAqKipcblJhbmtOYWRhbCAgICAgICAgICAgICAgICAwLjA4NTU2NCAgIDAuMDkxNzg2ICAgMC45MzIgICAgICAgICAgICAgMC4zNTEyMjcgICAgXG5SYW5rUml2YWwgICAgICAgICAgICAgICAgMC4wMDYxNDggICAwLjAwNzk2MyAgIDAuNzcyICAgICAgICAgICAgIDAuNDQwMDYyICAgIFxuLS0tXG5TaWduaWYuIGNvZGVzOiAgMCDigJgqKirigJkgMC4wMDEg4oCYKirigJkgMC4wMSDigJgq4oCZIDAuMDUg4oCYLuKAmSAwLjEg4oCYIOKAmSAxXG5cbihEaXNwZXJzaW9uIHBhcmFtZXRlciBmb3IgYmlub21pYWwgZmFtaWx5IHRha2VuIHRvIGJlIDEpXG5cbiAgICBOdWxsIGRldmlhbmNlOiA5MDAuOTcgIG9uIDEwMjMgIGRlZ3JlZXMgb2YgZnJlZWRvbVxuUmVzaWR1YWwgZGV2aWFuY2U6IDI0MS45NiAgb24gMTAwMiAgZGVncmVlcyBvZiBmcmVlZG9tXG5BSUM6IDI4NS45NlxuXG5OdW1iZXIgb2YgRmlzaGVyIFNjb3JpbmcgaXRlcmF0aW9uczogOFxuIn0= -->

```

Call:
glm(formula = Result ~ Surface + WRUlt3Meses + WRRivalUlt3Meses + 
    PartidosUlt3Meses + PartidosRivalUlt3Meses + WRUltMes + WRRivalUltMes + 
    PartidosUltMes + PartidosRivalUltMes + Round + BestOf + RankNadal + 
    RankRival, family = binomial, data = df_matches_train)

Deviance Residuals: 
    Min       1Q   Median       3Q      Max  
-3.6825   0.0024   0.0316   0.1514   2.6527  

Coefficients:
                         Estimate Std. Error z value             Pr(>|z|)    
(Intercept)             -6.452626   3.058645  -2.110             0.034890 *  
SurfaceClay              2.824457   1.432704   1.971             0.048676 *  
SurfaceGrass            -0.046893   1.587958  -0.030             0.976441    
SurfaceHard              1.156186   1.380059   0.838             0.402154    
WRUlt3Meses              0.454798   3.505492   0.130             0.896773    
WRRivalUlt3Meses        -0.727232   2.306633  -0.315             0.752550    
PartidosUlt3Meses       -0.043488   0.039882  -1.090             0.275530    
PartidosRivalUlt3Meses   0.027881   0.045397   0.614             0.539100    
WRUltMes                24.581012   3.032466   8.106 0.000000000000000523 ***
WRRivalUltMes          -24.153296   3.080994  -7.839 0.000000000000004525 ***
PartidosUltMes          -0.354390   0.084791  -4.180 0.000029205394127741 ***
PartidosRivalUltMes      0.213724   0.082560   2.589             0.009634 ** 
Round2nd Round           3.684232   0.969557   3.800             0.000145 ***
Round3rd Round           4.257775   0.982561   4.333 0.000014686012973884 ***
Round4th Round           6.199510   1.249921   4.960 0.000000705220525184 ***
RoundQuarterfinals       5.361470   1.092539   4.907 0.000000923155434077 ***
RoundRound Robin         5.207054   1.374810   3.787             0.000152 ***
RoundSemifinals          5.376587   1.124855   4.780 0.000001754657342896 ***
RoundThe Final           5.958590   1.270376   4.690 0.000002726542742763 ***
BestOf5                  1.623419   0.454911   3.569             0.000359 ***
RankNadal                0.085564   0.091786   0.932             0.351227    
RankRival                0.006148   0.007963   0.772             0.440062    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

(Dispersion parameter for binomial family taken to be 1)

    Null deviance: 900.97  on 1023  degrees of freedom
Residual deviance: 241.96  on 1002  degrees of freedom
AIC: 285.96

Number of Fisher Scoring iterations: 8
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuIyBNb2RlbG8gNSA9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PVxuXG5nbG0uZml0NSA8LSBnbG0oUmVzdWx0IH4gIFN1cmZhY2UgKyBXUlVsdE1lcyArIFxuICAgICAgICAgICAgICAgICAgV1JSaXZhbFVsdE1lcyArIFBhcnRpZG9zVWx0TWVzICsgUGFydGlkb3NSaXZhbFVsdE1lcyArXG4gICAgICAgICAgICAgICAgICBSb3VuZCArIEJlc3RPZiArIFJhbmtOYWRhbCArIFJhbmtSaXZhbCxcbiAgICAgICAgICAgICAgICBkYXRhID0gZGZfbWF0Y2hlc190cmFpbixcbiAgICAgICAgICAgICAgICBmYW1pbHkgPSBiaW5vbWlhbClcblxuc3VtbWFyeShnbG0uZml0NSlcbmBgYCJ9 -->

```r
# Modelo 5 =====================================================

glm.fit5 <- glm(Result ~  Surface + WRUltMes + 
                  WRRivalUltMes + PartidosUltMes + PartidosRivalUltMes +
                  Round + BestOf + RankNadal + RankRival,
                data = df_matches_train,
                family = binomial)

summary(glm.fit5)
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiXG5DYWxsOlxuZ2xtKGZvcm11bGEgPSBSZXN1bHQgfiBTdXJmYWNlICsgV1JVbHRNZXMgKyBXUlJpdmFsVWx0TWVzICsgUGFydGlkb3NVbHRNZXMgKyBcbiAgICBQYXJ0aWRvc1JpdmFsVWx0TWVzICsgUm91bmQgKyBCZXN0T2YgKyBSYW5rTmFkYWwgKyBSYW5rUml2YWwsIFxuICAgIGZhbWlseSA9IGJpbm9taWFsLCBkYXRhID0gZGZfbWF0Y2hlc190cmFpbilcblxuRGV2aWFuY2UgUmVzaWR1YWxzOiBcbiAgICBNaW4gICAgICAgMVEgICBNZWRpYW4gICAgICAgM1EgICAgICBNYXggIFxuLTMuNjU2MiAgIDAuMDAyNSAgIDAuMDMyMSAgIDAuMTQ3NCAgIDIuNjI4NyAgXG5cbkNvZWZmaWNpZW50czpcbiAgICAgICAgICAgICAgICAgICAgICBFc3RpbWF0ZSBTdGQuIEVycm9yIHogdmFsdWUgICAgICAgICAgICAgUHIoPnx6fCkgICAgXG4oSW50ZXJjZXB0KSAgICAgICAgICAtNi41OTEzMjEgICAyLjM4OTkyOSAgLTIuNzU4ICAgICAgICAgICAgIDAuMDA1ODE2ICoqIFxuU3VyZmFjZUNsYXkgICAgICAgICAgIDIuNzM0NzQyICAgMS4zNDg1NTggICAyLjAyOCAgICAgICAgICAgICAwLjA0MjU3MCAqICBcblN1cmZhY2VHcmFzcyAgICAgICAgIC0wLjU1MDI4OCAgIDEuNDE2OTQyICAtMC4zODggICAgICAgICAgICAgMC42OTc3NDcgICAgXG5TdXJmYWNlSGFyZCAgICAgICAgICAgMS4xMjc2ODUgICAxLjMwNjE5NyAgIDAuODYzICAgICAgICAgICAgIDAuMzg3OTU0ICAgIFxuV1JVbHRNZXMgICAgICAgICAgICAgMjQuNjA0MzA3ICAgMi43NDcwNDggICA4Ljk1NyA8IDAuMDAwMDAwMDAwMDAwMDAwMiAqKipcbldSUml2YWxVbHRNZXMgICAgICAgLTI0LjI2NDUyNyAgIDIuNzM5NjMyICAtOC44NTcgPCAwLjAwMDAwMDAwMDAwMDAwMDIgKioqXG5QYXJ0aWRvc1VsdE1lcyAgICAgICAtMC4zOTI1MDcgICAwLjA3NTIwNiAgLTUuMjE5ICAgICAgICAgIDAuMDAwMDAwMTgwICoqKlxuUGFydGlkb3NSaXZhbFVsdE1lcyAgIDAuMjI4MjIwICAgMC4wNjg1MDAgICAzLjMzMiAgICAgICAgICAgICAwLjAwMDg2MyAqKipcblJvdW5kMm5kIFJvdW5kICAgICAgICAzLjY5NzcwMiAgIDAuOTU5MDQ1ICAgMy44NTYgICAgICAgICAgICAgMC4wMDAxMTUgKioqXG5Sb3VuZDNyZCBSb3VuZCAgICAgICAgNC4yMDI4NDkgICAwLjk2Njg3NCAgIDQuMzQ3ICAgICAgICAgIDAuMDAwMDEzODExICoqKlxuUm91bmQ0dGggUm91bmQgICAgICAgIDYuMTM4MzkzICAgMS4yMjI2MDkgICA1LjAyMSAgICAgICAgICAwLjAwMDAwMDUxNSAqKipcblJvdW5kUXVhcnRlcmZpbmFscyAgICA1LjMzNzgzNyAgIDEuMDcxMDQzICAgNC45ODQgICAgICAgICAgMC4wMDAwMDA2MjQgKioqXG5Sb3VuZFJvdW5kIFJvYmluICAgICAgNS4yODA3MDMgICAxLjM3MzU5MSAgIDMuODQ0ICAgICAgICAgICAgIDAuMDAwMTIxICoqKlxuUm91bmRTZW1pZmluYWxzICAgICAgIDUuMzQ2MzEzICAgMS4xMDMyNjggICA0Ljg0NiAgICAgICAgICAwLjAwMDAwMTI2MCAqKipcblJvdW5kVGhlIEZpbmFsICAgICAgICA1Ljk1NjU3MSAgIDEuMjI1ODQzICAgNC44NTkgICAgICAgICAgMC4wMDAwMDExNzkgKioqXG5CZXN0T2Y1ICAgICAgICAgICAgICAgMS42NDkxNjggICAwLjQ0NDc4OSAgIDMuNzA4ICAgICAgICAgICAgIDAuMDAwMjA5ICoqKlxuUmFua05hZGFsICAgICAgICAgICAgIDAuMDk1NDQzICAgMC4wODE4NjQgICAxLjE2NiAgICAgICAgICAgICAwLjI0MzY2OSAgICBcblJhbmtSaXZhbCAgICAgICAgICAgICAwLjAwNTI3OSAgIDAuMDA3MTQ4ICAgMC43MzkgICAgICAgICAgICAgMC40NjAxNjAgICAgXG4tLS1cblNpZ25pZi4gY29kZXM6ICAwIOKAmCoqKuKAmSAwLjAwMSDigJgqKuKAmSAwLjAxIOKAmCrigJkgMC4wNSDigJgu4oCZIDAuMSDigJgg4oCZIDFcblxuKERpc3BlcnNpb24gcGFyYW1ldGVyIGZvciBiaW5vbWlhbCBmYW1pbHkgdGFrZW4gdG8gYmUgMSlcblxuICAgIE51bGwgZGV2aWFuY2U6IDkwMC45NyAgb24gMTAyMyAgZGVncmVlcyBvZiBmcmVlZG9tXG5SZXNpZHVhbCBkZXZpYW5jZTogMjQzLjQwICBvbiAxMDA2ICBkZWdyZWVzIG9mIGZyZWVkb21cbkFJQzogMjc5LjRcblxuTnVtYmVyIG9mIEZpc2hlciBTY29yaW5nIGl0ZXJhdGlvbnM6IDhcbiJ9 -->

```

Call:
glm(formula = Result ~ Surface + WRUltMes + WRRivalUltMes + PartidosUltMes + 
    PartidosRivalUltMes + Round + BestOf + RankNadal + RankRival, 
    family = binomial, data = df_matches_train)

Deviance Residuals: 
    Min       1Q   Median       3Q      Max  
-3.6562   0.0025   0.0321   0.1474   2.6287  

Coefficients:
                      Estimate Std. Error z value             Pr(>|z|)    
(Intercept)          -6.591321   2.389929  -2.758             0.005816 ** 
SurfaceClay           2.734742   1.348558   2.028             0.042570 *  
SurfaceGrass         -0.550288   1.416942  -0.388             0.697747    
SurfaceHard           1.127685   1.306197   0.863             0.387954    
WRUltMes             24.604307   2.747048   8.957 < 0.0000000000000002 ***
WRRivalUltMes       -24.264527   2.739632  -8.857 < 0.0000000000000002 ***
PartidosUltMes       -0.392507   0.075206  -5.219          0.000000180 ***
PartidosRivalUltMes   0.228220   0.068500   3.332             0.000863 ***
Round2nd Round        3.697702   0.959045   3.856             0.000115 ***
Round3rd Round        4.202849   0.966874   4.347          0.000013811 ***
Round4th Round        6.138393   1.222609   5.021          0.000000515 ***
RoundQuarterfinals    5.337837   1.071043   4.984          0.000000624 ***
RoundRound Robin      5.280703   1.373591   3.844             0.000121 ***
RoundSemifinals       5.346313   1.103268   4.846          0.000001260 ***
RoundThe Final        5.956571   1.225843   4.859          0.000001179 ***
BestOf5               1.649168   0.444789   3.708             0.000209 ***
RankNadal             0.095443   0.081864   1.166             0.243669    
RankRival             0.005279   0.007148   0.739             0.460160    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

(Dispersion parameter for binomial family taken to be 1)

    Null deviance: 900.97  on 1023  degrees of freedom
Residual deviance: 243.40  on 1006  degrees of freedom
AIC: 279.4

Number of Fisher Scoring iterations: 8
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuZ2xtLnByb2JzNSA8LSBwcmVkaWN0KGdsbS5maXQ1LCBkZl9tYXRjaGVzX3Rlc3QsXG4gICAgICAgICAgICAgICAgICAgICAgdHlwZSA9IFwicmVzcG9uc2VcIilcblxuZ2xtLnByZWQ1IDwtIHJlcChcIkxvc2VcIiwgbnJvdyhkZl9tYXRjaGVzX3Rlc3QpKVxuZ2xtLnByZWQ1W2dsbS5wcm9iczUgPiAwLjU1XSA9IFwiV2luXCJcblxudGFibGUoZ2xtLnByZWQ1LCBkZl9tYXRjaGVzX3Rlc3QkUmVzdWx0KSAjRW1wZW9yYVxuYGBgIn0= -->

```r
glm.probs5 <- predict(glm.fit5, df_matches_test,
                      type = "response")

glm.pred5 <- rep("Lose", nrow(df_matches_test))
glm.pred5[glm.probs5 > 0.55] = "Win"

table(glm.pred5, df_matches_test$Result) #Empeora
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiICAgICAgICAgXG5nbG0ucHJlZDUgTG9zZSBXaW5cbiAgICAgTG9zZSAgICA2ICAgMVxuICAgICBXaW4gICAgIDIgIDQwXG4ifQ== -->

```
         
glm.pred5 Lose Win
     Lose    6   1
     Win     2  40
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuIyBNb2RlbG8gNiA9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09XG5cbiNVc28gcmVzdWx0YWRvcyBkZWwgdWx0IG1lcyB5IGRlIGxvcyB1bHQgNiBtZXNlc1xuXG5nbG0uZml0NiA8LSBnbG0oUmVzdWx0IH4gIFN1cmZhY2UgKyBXUlVsdDZNZXNlcyArIFdSUml2YWxVbHQ2TWVzZXMgK1xuICAgICAgICAgICAgICAgICAgUGFydGlkb3NVbHQ2TWVzZXMgKyBQYXJ0aWRvc1JpdmFsVWx0Nk1lc2VzICsgV1JVbHRNZXMgKyBcbiAgICAgICAgICAgICAgICAgIFdSUml2YWxVbHRNZXMgKyBQYXJ0aWRvc1VsdE1lcyArIFBhcnRpZG9zUml2YWxVbHRNZXMgK1xuICAgICAgICAgICAgICAgICAgUm91bmQgKyBCZXN0T2YgKyBSZXN1bHRVbHRQYXJ0aWRvLFxuICAgICAgICAgICAgICAgIGRhdGEgPSBkZl9tYXRjaGVzX3RyYWluLFxuICAgICAgICAgICAgICAgIGZhbWlseSA9IGJpbm9taWFsKVxuXG5zdW1tYXJ5KGdsbS5maXQ2KVxuYGBgIn0= -->

```r
# Modelo 6 ====================================================

#Uso resultados del ult mes y de los ult 6 meses

glm.fit6 <- glm(Result ~  Surface + WRUlt6Meses + WRRivalUlt6Meses +
                  PartidosUlt6Meses + PartidosRivalUlt6Meses + WRUltMes + 
                  WRRivalUltMes + PartidosUltMes + PartidosRivalUltMes +
                  Round + BestOf + ResultUltPartido,
                data = df_matches_train,
                family = binomial)

summary(glm.fit6)
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiXG5DYWxsOlxuZ2xtKGZvcm11bGEgPSBSZXN1bHQgfiBTdXJmYWNlICsgV1JVbHQ2TWVzZXMgKyBXUlJpdmFsVWx0Nk1lc2VzICsgXG4gICAgUGFydGlkb3NVbHQ2TWVzZXMgKyBQYXJ0aWRvc1JpdmFsVWx0Nk1lc2VzICsgV1JVbHRNZXMgKyBXUlJpdmFsVWx0TWVzICsgXG4gICAgUGFydGlkb3NVbHRNZXMgKyBQYXJ0aWRvc1JpdmFsVWx0TWVzICsgUm91bmQgKyBCZXN0T2YgKyBSZXN1bHRVbHRQYXJ0aWRvLCBcbiAgICBmYW1pbHkgPSBiaW5vbWlhbCwgZGF0YSA9IGRmX21hdGNoZXNfdHJhaW4pXG5cbkRldmlhbmNlIFJlc2lkdWFsczogXG4gICAgTWluICAgICAgIDFRICAgTWVkaWFuICAgICAgIDNRICAgICAgTWF4ICBcbi0zLjM3MTAgICAwLjAwMTggICAwLjAyODIgICAwLjE0MzUgICAyLjYxOTkgIFxuXG5Db2VmZmljaWVudHM6XG4gICAgICAgICAgICAgICAgICAgICAgICAgRXN0aW1hdGUgU3RkLiBFcnJvciB6IHZhbHVlICAgICAgICAgICAgIFByKD58enwpICAgIFxuKEludGVyY2VwdCkgICAgICAgICAgICAgLTEuMjcxNzI1ICAgMi45MTA2OTAgIC0wLjQzNyAgICAgICAgICAgICAwLjY2MjE3MyAgICBcblN1cmZhY2VDbGF5ICAgICAgICAgICAgICAyLjQ1MjUwNCAgIDEuMzg5MTE2ICAgMS43NjYgICAgICAgICAgICAgMC4wNzc0NzcgLiAgXG5TdXJmYWNlR3Jhc3MgICAgICAgICAgICAtMC40NTIyNDkgICAxLjQzNjEzNSAgLTAuMzE1ICAgICAgICAgICAgIDAuNzUyODMyICAgIFxuU3VyZmFjZUhhcmQgICAgICAgICAgICAgIDAuOTQ5MDYyICAgMS4zMjk5NDMgICAwLjcxNCAgICAgICAgICAgICAwLjQ3NTQ2OCAgICBcbldSVWx0Nk1lc2VzICAgICAgICAgICAgIC02LjE0OTYxNCAgIDIuOTgxMDgwICAtMi4wNjMgICAgICAgICAgICAgMC4wMzkxMjQgKiAgXG5XUlJpdmFsVWx0Nk1lc2VzICAgICAgICAtMC4xNDg2ODIgICAyLjI1MzAxNiAgLTAuMDY2ICAgICAgICAgICAgIDAuOTQ3Mzg0ICAgIFxuUGFydGlkb3NVbHQ2TWVzZXMgICAgICAgIDAuMDAzOTQ1ICAgMC4wMTk4OTQgICAwLjE5OCAgICAgICAgICAgICAwLjg0MjgwMiAgICBcblBhcnRpZG9zUml2YWxVbHQ2TWVzZXMgIC0wLjAxMzA4MSAgIDAuMDI3MjU3ICAtMC40ODAgICAgICAgICAgICAgMC42MzEyOTQgICAgXG5XUlVsdE1lcyAgICAgICAgICAgICAgICAyNy41MDQ3NzYgICAzLjE0MTI5NiAgIDguNzU2IDwgMC4wMDAwMDAwMDAwMDAwMDAyICoqKlxuV1JSaXZhbFVsdE1lcyAgICAgICAgICAtMjUuODIzMTUxICAgMy4wNDExMjMgIC04LjQ5MSA8IDAuMDAwMDAwMDAwMDAwMDAwMiAqKipcblBhcnRpZG9zVWx0TWVzICAgICAgICAgIC0wLjQwOTY3MSAgIDAuMDgzMDU5ICAtNC45MzIgICAgICAgICAwLjAwMDAwMDgxMjcgKioqXG5QYXJ0aWRvc1JpdmFsVWx0TWVzICAgICAgMC4yNTk3MjYgICAwLjA3NzUxNSAgIDMuMzUxICAgICAgICAgICAgIDAuMDAwODA2ICoqKlxuUm91bmQybmQgUm91bmQgICAgICAgICAgIDQuNTQxODU3ICAgMS4wODg1MDIgICA0LjE3MyAgICAgICAgIDAuMDAwMDMwMTE3NCAqKipcblJvdW5kM3JkIFJvdW5kICAgICAgICAgICA1Ljk4OTIwOCAgIDEuMjMyNzYyICAgNC44NTggICAgICAgICAwLjAwMDAwMTE4MzYgKioqXG5Sb3VuZDR0aCBSb3VuZCAgICAgICAgICAgOC4wMDgxMjMgICAxLjQ4NDI1NiAgIDUuMzk1ICAgICAgICAgMC4wMDAwMDAwNjg0ICoqKlxuUm91bmRRdWFydGVyZmluYWxzICAgICAgIDcuMTUzMzExICAgMS4zNDE5NDAgICA1LjMzMSAgICAgICAgIDAuMDAwMDAwMDk3OSAqKipcblJvdW5kUm91bmQgUm9iaW4gICAgICAgICA2LjY3NDcxNSAgIDEuNTE1NTY0ICAgNC40MDQgICAgICAgICAwLjAwMDAxMDYyMTggKioqXG5Sb3VuZFNlbWlmaW5hbHMgICAgICAgICAgNy4yMjI4NjYgICAxLjM4MDEyMiAgIDUuMjMzICAgICAgICAgMC4wMDAwMDAxNjYzICoqKlxuUm91bmRUaGUgRmluYWwgICAgICAgICAgIDguMDQ4MjEyICAgMS41MzAzMjQgICA1LjI1OSAgICAgICAgIDAuMDAwMDAwMTQ0NyAqKipcbkJlc3RPZjUgICAgICAgICAgICAgICAgICAxLjgwNjgwMSAgIDAuNDY0MjQ4ICAgMy44OTIgICAgICAgICAwLjAwMDA5OTQ2NzQgKioqXG5SZXN1bHRVbHRQYXJ0aWRvV2luICAgICAtMi41MjA0NzcgICAwLjkxNDI1MSAgLTIuNzU3ICAgICAgICAgICAgIDAuMDA1ODM2ICoqIFxuLS0tXG5TaWduaWYuIGNvZGVzOiAgMCDigJgqKirigJkgMC4wMDEg4oCYKirigJkgMC4wMSDigJgq4oCZIDAuMDUg4oCYLuKAmSAwLjEg4oCYIOKAmSAxXG5cbihEaXNwZXJzaW9uIHBhcmFtZXRlciBmb3IgYmlub21pYWwgZmFtaWx5IHRha2VuIHRvIGJlIDEpXG5cbiAgICBOdWxsIGRldmlhbmNlOiA5MDAuOTcgIG9uIDEwMjMgIGRlZ3JlZXMgb2YgZnJlZWRvbVxuUmVzaWR1YWwgZGV2aWFuY2U6IDIzMi42NCAgb24gMTAwMyAgZGVncmVlcyBvZiBmcmVlZG9tXG5BSUM6IDI3NC42NFxuXG5OdW1iZXIgb2YgRmlzaGVyIFNjb3JpbmcgaXRlcmF0aW9uczogOFxuIn0= -->

```

Call:
glm(formula = Result ~ Surface + WRUlt6Meses + WRRivalUlt6Meses + 
    PartidosUlt6Meses + PartidosRivalUlt6Meses + WRUltMes + WRRivalUltMes + 
    PartidosUltMes + PartidosRivalUltMes + Round + BestOf + ResultUltPartido, 
    family = binomial, data = df_matches_train)

Deviance Residuals: 
    Min       1Q   Median       3Q      Max  
-3.3710   0.0018   0.0282   0.1435   2.6199  

Coefficients:
                         Estimate Std. Error z value             Pr(>|z|)    
(Intercept)             -1.271725   2.910690  -0.437             0.662173    
SurfaceClay              2.452504   1.389116   1.766             0.077477 .  
SurfaceGrass            -0.452249   1.436135  -0.315             0.752832    
SurfaceHard              0.949062   1.329943   0.714             0.475468    
WRUlt6Meses             -6.149614   2.981080  -2.063             0.039124 *  
WRRivalUlt6Meses        -0.148682   2.253016  -0.066             0.947384    
PartidosUlt6Meses        0.003945   0.019894   0.198             0.842802    
PartidosRivalUlt6Meses  -0.013081   0.027257  -0.480             0.631294    
WRUltMes                27.504776   3.141296   8.756 < 0.0000000000000002 ***
WRRivalUltMes          -25.823151   3.041123  -8.491 < 0.0000000000000002 ***
PartidosUltMes          -0.409671   0.083059  -4.932         0.0000008127 ***
PartidosRivalUltMes      0.259726   0.077515   3.351             0.000806 ***
Round2nd Round           4.541857   1.088502   4.173         0.0000301174 ***
Round3rd Round           5.989208   1.232762   4.858         0.0000011836 ***
Round4th Round           8.008123   1.484256   5.395         0.0000000684 ***
RoundQuarterfinals       7.153311   1.341940   5.331         0.0000000979 ***
RoundRound Robin         6.674715   1.515564   4.404         0.0000106218 ***
RoundSemifinals          7.222866   1.380122   5.233         0.0000001663 ***
RoundThe Final           8.048212   1.530324   5.259         0.0000001447 ***
BestOf5                  1.806801   0.464248   3.892         0.0000994674 ***
ResultUltPartidoWin     -2.520477   0.914251  -2.757             0.005836 ** 
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

(Dispersion parameter for binomial family taken to be 1)

    Null deviance: 900.97  on 1023  degrees of freedom
Residual deviance: 232.64  on 1003  degrees of freedom
AIC: 274.64

Number of Fisher Scoring iterations: 8
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuZ2xtLnByb2JzNiA8LSBwcmVkaWN0KGdsbS5maXQ2LCBkZl9tYXRjaGVzX3Rlc3QsXG4gICAgICAgICAgICAgICAgICAgICAgdHlwZSA9IFwicmVzcG9uc2VcIilcblxuZ2xtLnByZWQ2IDwtIHJlcChcIkxvc2VcIiwgbnJvdyhkZl9tYXRjaGVzX3Rlc3QpKVxuZ2xtLnByZWQ2W2dsbS5wcm9iczYgPiAwLjU1XSA9IFwiV2luXCJcblxudGFibGUoZ2xtLnByZWQ2LCBkZl9tYXRjaGVzX3Rlc3QkUmVzdWx0KVxuYGBgIn0= -->

```r
glm.probs6 <- predict(glm.fit6, df_matches_test,
                      type = "response")

glm.pred6 <- rep("Lose", nrow(df_matches_test))
glm.pred6[glm.probs6 > 0.55] = "Win"

table(glm.pred6, df_matches_test$Result)
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiICAgICAgICAgXG5nbG0ucHJlZDYgTG9zZSBXaW5cbiAgICAgTG9zZSAgICA2ICAgMVxuICAgICBXaW4gICAgIDIgIDQwXG4ifQ== -->

```
         
glm.pred6 Lose Win
     Lose    6   1
     Win     2  40
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuI0xhIGluZm8gZGVsIHVsdGltbyBwYXJ0aWRvIG5vIGVzIG11eSByZWxldmFudGVcblxuIyBNb2RlbG8gNyA9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PVxuXG4jUHJ1ZWJvIHNvbG8gY29uIGluZm8gdWx0IG1lcyB5IHVsdCA2IG1hcyBleHRyYXNcblxuZ2xtLmZpdDcgPC0gZ2xtKFJlc3VsdCB+ICBTdXJmYWNlICsgV1JVbHQzTWVzZXMgKyBXUlJpdmFsVWx0M01lc2VzICtcbiAgICAgICAgICAgICAgICAgIFBhcnRpZG9zVWx0M01lc2VzICsgUGFydGlkb3NSaXZhbFVsdDNNZXNlcyArIFdSVWx0TWVzICsgXG4gICAgICAgICAgICAgICAgICBXUlJpdmFsVWx0TWVzICsgUGFydGlkb3NVbHRNZXMgKyBQYXJ0aWRvc1JpdmFsVWx0TWVzICtcbiAgICAgICAgICAgICAgICAgIFJvdW5kICsgQmVzdE9mICsgUmFua05hZGFsICsgUmFua1JpdmFsLFxuICAgICAgICAgICAgICAgIGRhdGEgPSBkZl9tYXRjaGVzX3RyYWluLFxuICAgICAgICAgICAgICAgIGZhbWlseSA9IGJpbm9taWFsKVxuXG5zdW1tYXJ5KGdsbS5maXQ3KVxuYGBgIn0= -->

```r
#La info del ultimo partido no es muy relevante

# Modelo 7 =====================================================

#Pruebo solo con info ult mes y ult 6 mas extras

glm.fit7 <- glm(Result ~  Surface + WRUlt3Meses + WRRivalUlt3Meses +
                  PartidosUlt3Meses + PartidosRivalUlt3Meses + WRUltMes + 
                  WRRivalUltMes + PartidosUltMes + PartidosRivalUltMes +
                  Round + BestOf + RankNadal + RankRival,
                data = df_matches_train,
                family = binomial)

summary(glm.fit7)
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiXG5DYWxsOlxuZ2xtKGZvcm11bGEgPSBSZXN1bHQgfiBTdXJmYWNlICsgV1JVbHQzTWVzZXMgKyBXUlJpdmFsVWx0M01lc2VzICsgXG4gICAgUGFydGlkb3NVbHQzTWVzZXMgKyBQYXJ0aWRvc1JpdmFsVWx0M01lc2VzICsgV1JVbHRNZXMgKyBXUlJpdmFsVWx0TWVzICsgXG4gICAgUGFydGlkb3NVbHRNZXMgKyBQYXJ0aWRvc1JpdmFsVWx0TWVzICsgUm91bmQgKyBCZXN0T2YgKyBSYW5rTmFkYWwgKyBcbiAgICBSYW5rUml2YWwsIGZhbWlseSA9IGJpbm9taWFsLCBkYXRhID0gZGZfbWF0Y2hlc190cmFpbilcblxuRGV2aWFuY2UgUmVzaWR1YWxzOiBcbiAgICBNaW4gICAgICAgMVEgICBNZWRpYW4gICAgICAgM1EgICAgICBNYXggIFxuLTMuNjgyNSAgIDAuMDAyNCAgIDAuMDMxNiAgIDAuMTUxNCAgIDIuNjUyNyAgXG5cbkNvZWZmaWNpZW50czpcbiAgICAgICAgICAgICAgICAgICAgICAgICBFc3RpbWF0ZSBTdGQuIEVycm9yIHogdmFsdWUgICAgICAgICAgICAgUHIoPnx6fCkgICAgXG4oSW50ZXJjZXB0KSAgICAgICAgICAgICAtNi40NTI2MjYgICAzLjA1ODY0NSAgLTIuMTEwICAgICAgICAgICAgIDAuMDM0ODkwICogIFxuU3VyZmFjZUNsYXkgICAgICAgICAgICAgIDIuODI0NDU3ICAgMS40MzI3MDQgICAxLjk3MSAgICAgICAgICAgICAwLjA0ODY3NiAqICBcblN1cmZhY2VHcmFzcyAgICAgICAgICAgIC0wLjA0Njg5MyAgIDEuNTg3OTU4ICAtMC4wMzAgICAgICAgICAgICAgMC45NzY0NDEgICAgXG5TdXJmYWNlSGFyZCAgICAgICAgICAgICAgMS4xNTYxODYgICAxLjM4MDA1OSAgIDAuODM4ICAgICAgICAgICAgIDAuNDAyMTU0ICAgIFxuV1JVbHQzTWVzZXMgICAgICAgICAgICAgIDAuNDU0Nzk4ICAgMy41MDU0OTIgICAwLjEzMCAgICAgICAgICAgICAwLjg5Njc3MyAgICBcbldSUml2YWxVbHQzTWVzZXMgICAgICAgIC0wLjcyNzIzMiAgIDIuMzA2NjMzICAtMC4zMTUgICAgICAgICAgICAgMC43NTI1NTAgICAgXG5QYXJ0aWRvc1VsdDNNZXNlcyAgICAgICAtMC4wNDM0ODggICAwLjAzOTg4MiAgLTEuMDkwICAgICAgICAgICAgIDAuMjc1NTMwICAgIFxuUGFydGlkb3NSaXZhbFVsdDNNZXNlcyAgIDAuMDI3ODgxICAgMC4wNDUzOTcgICAwLjYxNCAgICAgICAgICAgICAwLjUzOTEwMCAgICBcbldSVWx0TWVzICAgICAgICAgICAgICAgIDI0LjU4MTAxMiAgIDMuMDMyNDY2ICAgOC4xMDYgMC4wMDAwMDAwMDAwMDAwMDA1MjMgKioqXG5XUlJpdmFsVWx0TWVzICAgICAgICAgIC0yNC4xNTMyOTYgICAzLjA4MDk5NCAgLTcuODM5IDAuMDAwMDAwMDAwMDAwMDA0NTI1ICoqKlxuUGFydGlkb3NVbHRNZXMgICAgICAgICAgLTAuMzU0MzkwICAgMC4wODQ3OTEgIC00LjE4MCAwLjAwMDAyOTIwNTM5NDEyNzc0MSAqKipcblBhcnRpZG9zUml2YWxVbHRNZXMgICAgICAwLjIxMzcyNCAgIDAuMDgyNTYwICAgMi41ODkgICAgICAgICAgICAgMC4wMDk2MzQgKiogXG5Sb3VuZDJuZCBSb3VuZCAgICAgICAgICAgMy42ODQyMzIgICAwLjk2OTU1NyAgIDMuODAwICAgICAgICAgICAgIDAuMDAwMTQ1ICoqKlxuUm91bmQzcmQgUm91bmQgICAgICAgICAgIDQuMjU3Nzc1ICAgMC45ODI1NjEgICA0LjMzMyAwLjAwMDAxNDY4NjAxMjk3Mzg4NCAqKipcblJvdW5kNHRoIFJvdW5kICAgICAgICAgICA2LjE5OTUxMCAgIDEuMjQ5OTIxICAgNC45NjAgMC4wMDAwMDA3MDUyMjA1MjUxODQgKioqXG5Sb3VuZFF1YXJ0ZXJmaW5hbHMgICAgICAgNS4zNjE0NzAgICAxLjA5MjUzOSAgIDQuOTA3IDAuMDAwMDAwOTIzMTU1NDM0MDc3ICoqKlxuUm91bmRSb3VuZCBSb2JpbiAgICAgICAgIDUuMjA3MDU0ICAgMS4zNzQ4MTAgICAzLjc4NyAgICAgICAgICAgICAwLjAwMDE1MiAqKipcblJvdW5kU2VtaWZpbmFscyAgICAgICAgICA1LjM3NjU4NyAgIDEuMTI0ODU1ICAgNC43ODAgMC4wMDAwMDE3NTQ2NTczNDI4OTYgKioqXG5Sb3VuZFRoZSBGaW5hbCAgICAgICAgICAgNS45NTg1OTAgICAxLjI3MDM3NiAgIDQuNjkwIDAuMDAwMDAyNzI2NTQyNzQyNzYzICoqKlxuQmVzdE9mNSAgICAgICAgICAgICAgICAgIDEuNjIzNDE5ICAgMC40NTQ5MTEgICAzLjU2OSAgICAgICAgICAgICAwLjAwMDM1OSAqKipcblJhbmtOYWRhbCAgICAgICAgICAgICAgICAwLjA4NTU2NCAgIDAuMDkxNzg2ICAgMC45MzIgICAgICAgICAgICAgMC4zNTEyMjcgICAgXG5SYW5rUml2YWwgICAgICAgICAgICAgICAgMC4wMDYxNDggICAwLjAwNzk2MyAgIDAuNzcyICAgICAgICAgICAgIDAuNDQwMDYyICAgIFxuLS0tXG5TaWduaWYuIGNvZGVzOiAgMCDigJgqKirigJkgMC4wMDEg4oCYKirigJkgMC4wMSDigJgq4oCZIDAuMDUg4oCYLuKAmSAwLjEg4oCYIOKAmSAxXG5cbihEaXNwZXJzaW9uIHBhcmFtZXRlciBmb3IgYmlub21pYWwgZmFtaWx5IHRha2VuIHRvIGJlIDEpXG5cbiAgICBOdWxsIGRldmlhbmNlOiA5MDAuOTcgIG9uIDEwMjMgIGRlZ3JlZXMgb2YgZnJlZWRvbVxuUmVzaWR1YWwgZGV2aWFuY2U6IDI0MS45NiAgb24gMTAwMiAgZGVncmVlcyBvZiBmcmVlZG9tXG5BSUM6IDI4NS45NlxuXG5OdW1iZXIgb2YgRmlzaGVyIFNjb3JpbmcgaXRlcmF0aW9uczogOFxuIn0= -->

```

Call:
glm(formula = Result ~ Surface + WRUlt3Meses + WRRivalUlt3Meses + 
    PartidosUlt3Meses + PartidosRivalUlt3Meses + WRUltMes + WRRivalUltMes + 
    PartidosUltMes + PartidosRivalUltMes + Round + BestOf + RankNadal + 
    RankRival, family = binomial, data = df_matches_train)

Deviance Residuals: 
    Min       1Q   Median       3Q      Max  
-3.6825   0.0024   0.0316   0.1514   2.6527  

Coefficients:
                         Estimate Std. Error z value             Pr(>|z|)    
(Intercept)             -6.452626   3.058645  -2.110             0.034890 *  
SurfaceClay              2.824457   1.432704   1.971             0.048676 *  
SurfaceGrass            -0.046893   1.587958  -0.030             0.976441    
SurfaceHard              1.156186   1.380059   0.838             0.402154    
WRUlt3Meses              0.454798   3.505492   0.130             0.896773    
WRRivalUlt3Meses        -0.727232   2.306633  -0.315             0.752550    
PartidosUlt3Meses       -0.043488   0.039882  -1.090             0.275530    
PartidosRivalUlt3Meses   0.027881   0.045397   0.614             0.539100    
WRUltMes                24.581012   3.032466   8.106 0.000000000000000523 ***
WRRivalUltMes          -24.153296   3.080994  -7.839 0.000000000000004525 ***
PartidosUltMes          -0.354390   0.084791  -4.180 0.000029205394127741 ***
PartidosRivalUltMes      0.213724   0.082560   2.589             0.009634 ** 
Round2nd Round           3.684232   0.969557   3.800             0.000145 ***
Round3rd Round           4.257775   0.982561   4.333 0.000014686012973884 ***
Round4th Round           6.199510   1.249921   4.960 0.000000705220525184 ***
RoundQuarterfinals       5.361470   1.092539   4.907 0.000000923155434077 ***
RoundRound Robin         5.207054   1.374810   3.787             0.000152 ***
RoundSemifinals          5.376587   1.124855   4.780 0.000001754657342896 ***
RoundThe Final           5.958590   1.270376   4.690 0.000002726542742763 ***
BestOf5                  1.623419   0.454911   3.569             0.000359 ***
RankNadal                0.085564   0.091786   0.932             0.351227    
RankRival                0.006148   0.007963   0.772             0.440062    
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

(Dispersion parameter for binomial family taken to be 1)

    Null deviance: 900.97  on 1023  degrees of freedom
Residual deviance: 241.96  on 1002  degrees of freedom
AIC: 285.96

Number of Fisher Scoring iterations: 8
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuZ2xtLnByb2JzNyA8LSBwcmVkaWN0KGdsbS5maXQ3LCBkZl9tYXRjaGVzX3Rlc3QsXG4gICAgICAgICAgICAgICAgICAgICAgdHlwZSA9IFwicmVzcG9uc2VcIilcblxuZ2xtLnByZWQ3IDwtIHJlcChcIkxvc2VcIiwgbnJvdyhkZl9tYXRjaGVzX3Rlc3QpKVxuZ2xtLnByZWQ3W2dsbS5wcm9iczcgPiAwLjU1XSA9IFwiV2luXCJcblxudGFibGUoZ2xtLnByZWQ3LCBkZl9tYXRjaGVzX3Rlc3QkUmVzdWx0KVxuYGBgIn0= -->

```r
glm.probs7 <- predict(glm.fit7, df_matches_test,
                      type = "response")

glm.pred7 <- rep("Lose", nrow(df_matches_test))
glm.pred7[glm.probs7 > 0.55] = "Win"

table(glm.pred7, df_matches_test$Result)
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiICAgICAgICAgXG5nbG0ucHJlZDcgTG9zZSBXaW5cbiAgICAgTG9zZSAgICA1ICAgMFxuICAgICBXaW4gICAgIDMgIDQxXG4ifQ== -->

```
         
glm.pred7 Lose Win
     Lose    5   0
     Win     3  41
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuI0xhcyBkZWwgbW9kZWxvIDcgc2VyYW4gbGFzIHZhcmlhYmxlcyBzZWxlY2Npb25hZGFzLlxuI0Fob3JhIHRyYWJham8gZW4gbGEgZmxleGliaWxpZGFkIGRlbCBtb2RlbG9cblxuXG5cbmBgYCJ9 -->

```r
#Las del modelo 7 seran las variables seleccionadas.
#Ahora trabajo en la flexibilidad del modelo

```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->


###Errores por CV

Calculo el error utilizando CV para cada uno de los modelos ajustados.



<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuXG4jIE1PREVMIEZMRVhJQklMSVRZICMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyNcblxuI0NWIHRlc3QgZXJyb3IgZ2xtLmZpdDcgPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09XG5cbnNldC5zZWVkKDE3KVxuXG5jdi5lcnJvciA8LSBjdi5nbG0oZGZfbWF0Y2hlc190cmFpbixcbiAgICAgICAgICAgICAgICAgICBnbG0uZml0NyxcbiAgICAgICAgICAgICAgICAgICBLID0gMTApXG5gYGAifQ== -->

```r

# MODEL FLEXIBILITY ###########################################

#CV test error glm.fit7 =======================================

set.seed(17)

cv.error <- cv.glm(df_matches_train,
                   glm.fit7,
                   K = 10)
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkXG4ifQ== -->

```
glm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurred
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuY3YuZXJyb3IkZGVsdGFcbmBgYCJ9 -->

```r
cv.error$delta
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiWzFdIDAuMDQxNjMzOTIgMC4wNDEyNDExOVxuIn0= -->

```
[1] 0.04163392 0.04124119
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuI0NWIHRlc3QgZXJyb3IgY29tcGFyaXNvbiA9PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09XG5cbnNldC5zZWVkKDI0KVxuY3YuZXJyb3IgPC0gcmVwKDAsIDcpXG5cbmZvciAoaSBpbiAxOjcpIHtcbiAgXG4gIGN2LmVycm9yW2ldID0gXG4gICAgY3YuZ2xtKGRmX21hdGNoZXNfdHJhaW4sXG4gICAgICAgICAgIGdldChcbiAgICAgICAgICAgICBwYXN0ZShcImdsbS5maXRcIiwgaSwgc2VwID0gXCJcIilcbiAgICAgICAgICAgICApLFxuICAgICAgICAgICBLID0gMTApJGRlbHRhWzFdXG4gIFxufVxuYGBgIn0= -->

```r
#CV test error comparison =====================================

set.seed(24)
cv.error <- rep(0, 7)

for (i in 1:7) {
  
  cv.error[i] = 
    cv.glm(df_matches_train,
           get(
             paste("glm.fit", i, sep = "")
             ),
           K = 10)$delta[1]
  
}
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkbG9uZ2VyIG9iamVjdCBsZW5ndGggaXMgbm90IGEgbXVsdGlwbGUgb2Ygc2hvcnRlciBvYmplY3QgbGVuZ3RoZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkbG9uZ2VyIG9iamVjdCBsZW5ndGggaXMgbm90IGEgbXVsdGlwbGUgb2Ygc2hvcnRlciBvYmplY3QgbGVuZ3RoZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkbG9uZ2VyIG9iamVjdCBsZW5ndGggaXMgbm90IGEgbXVsdGlwbGUgb2Ygc2hvcnRlciBvYmplY3QgbGVuZ3RoZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkbG9uZ2VyIG9iamVjdCBsZW5ndGggaXMgbm90IGEgbXVsdGlwbGUgb2Ygc2hvcnRlciBvYmplY3QgbGVuZ3RoZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkbG9uZ2VyIG9iamVjdCBsZW5ndGggaXMgbm90IGEgbXVsdGlwbGUgb2Ygc2hvcnRlciBvYmplY3QgbGVuZ3RoZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkbG9uZ2VyIG9iamVjdCBsZW5ndGggaXMgbm90IGEgbXVsdGlwbGUgb2Ygc2hvcnRlciBvYmplY3QgbGVuZ3RoZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkbG9uZ2VyIG9iamVjdCBsZW5ndGggaXMgbm90IGEgbXVsdGlwbGUgb2Ygc2hvcnRlciBvYmplY3QgbGVuZ3RoZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkbG9uZ2VyIG9iamVjdCBsZW5ndGggaXMgbm90IGEgbXVsdGlwbGUgb2Ygc2hvcnRlciBvYmplY3QgbGVuZ3RoZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkbG9uZ2VyIG9iamVjdCBsZW5ndGggaXMgbm90IGEgbXVsdGlwbGUgb2Ygc2hvcnRlciBvYmplY3QgbGVuZ3RoZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkbG9uZ2VyIG9iamVjdCBsZW5ndGggaXMgbm90IGEgbXVsdGlwbGUgb2Ygc2hvcnRlciBvYmplY3QgbGVuZ3RoZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkXG4ifQ== -->

```
glm.fit: fitted probabilities numerically 0 or 1 occurredlonger object length is not a multiple of shorter object lengthglm.fit: fitted probabilities numerically 0 or 1 occurredlonger object length is not a multiple of shorter object lengthglm.fit: fitted probabilities numerically 0 or 1 occurredlonger object length is not a multiple of shorter object lengthglm.fit: fitted probabilities numerically 0 or 1 occurredlonger object length is not a multiple of shorter object lengthglm.fit: fitted probabilities numerically 0 or 1 occurredlonger object length is not a multiple of shorter object lengthglm.fit: fitted probabilities numerically 0 or 1 occurredlonger object length is not a multiple of shorter object lengthglm.fit: fitted probabilities numerically 0 or 1 occurredlonger object length is not a multiple of shorter object lengthglm.fit: fitted probabilities numerically 0 or 1 occurredlonger object length is not a multiple of shorter object lengthglm.fit: fitted probabilities numerically 0 or 1 occurredlonger object length is not a multiple of shorter object lengthglm.fit: fitted probabilities numerically 0 or 1 occurredlonger object length is not a multiple of shorter object lengthglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurred
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuY3YuZXJyb3IgJTw+JVxuICBhc190aWJibGUoKSAlPiUgXG4gIG11dGF0ZShNb2RlbG8gPSBzZXEoMTo3KSkgJT4lIFxuICByZW5hbWUoY3YuZXJyb3IgPSB2YWx1ZSlcblxuY3YuZXJyb3IgJT4lIFxuICBnZ3Bsb3QoYWVzKHggPSBNb2RlbG8sIHkgPSBjdi5lcnJvcikpICtcbiAgZ2VvbV9saW5lKCkgKyBcbiAgZ2VvbV9wb2ludCgpICsgXG4gIHRoZW1lX2NsYXNzaWMoKSArIFxuICBzY2FsZV94X2NvbnRpbnVvdXMobi5icmVha3MgPSA3KVxuYGBgIn0= -->

```r
cv.error %<>%
  as_tibble() %>% 
  mutate(Modelo = seq(1:7)) %>% 
  rename(cv.error = value)

cv.error %>% 
  ggplot(aes(x = Modelo, y = cv.error)) +
  geom_line() + 
  geom_point() + 
  theme_classic() + 
  scale_x_continuous(n.breaks = 7)
```

<!-- rnb-source-end -->

<!-- rnb-plot-begin eyJoZWlnaHQiOjQzMi42MzI5LCJ3aWR0aCI6NzAwLCJzaXplX2JlaGF2aW9yIjowLCJjb25kaXRpb25zIjpbWzEsIlJlbW92ZWQgMSByb3cocykgY29udGFpbmluZyBtaXNzaW5nIHZhbHVlcyAoZ2VvbV9wYXRoKS4iXSxbMSwiUmVtb3ZlZCAxIHJvd3MgY29udGFpbmluZyBtaXNzaW5nIHZhbHVlcyAoZ2VvbV9wb2ludCkuIl1dfQ== -->

<img src="data:image/png;base64,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" />

<!-- rnb-plot-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuTkFcbk5BXG5OQVxuYGBgIn0= -->

```r
NA
NA
NA
```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->


Trabajo ahora sobre la flexibilidad en el modelo 3.


<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuXG5zZXQuc2VlZCgxNylcblxuY3YuZXJyb3IuZmxleCA8LSByZXAoMCwgNylcblxuZm9yIChpIGluIDE6Nykge1xuXG5nbG0uZml0My5mbGV4PC0gZ2xtKFJlc3VsdCB+IFN1cmZhY2UgKyBXUlVsdDNNZXNlcyArIFdSUml2YWxVbHQzTWVzZXMgK1xuICAgICAgICAgICAgICAgICAgICAgICBQYXJ0aWRvc1VsdDNNZXNlcyArIFBhcnRpZG9zUml2YWxVbHQzTWVzZXMgKyBwb2x5KFdSVWx0TWVzLCBpKSArIFxuICAgICAgICAgICAgICAgICAgICAgICBwb2x5KFdSUml2YWxVbHRNZXMsIGkpICsgcG9seShQYXJ0aWRvc1VsdE1lcywgaSkgK1xuICAgICAgICAgICAgICAgICAgICAgICBwb2x5KFBhcnRpZG9zUml2YWxVbHRNZXMsIGkpICtcbiAgICAgICAgICAgICAgICAgICAgICAgV1JVbHQ2TWVzZXMgKyBXUlJpdmFsVWx0Nk1lc2VzICsgUGFydGlkb3NVbHQ2TWVzZXMgK1xuICAgICAgICAgICAgICAgICAgICAgICBQYXJ0aWRvc1JpdmFsVWx0Nk1lc2VzICsgUm91bmQgKyBCZXN0T2YsXG4gICAgICAgICAgICAgICAgICAgICBkYXRhID0gZGZfbWF0Y2hlc190cmFpbixcbiAgICAgICAgICAgICAgICAgICAgIGZhbWlseSA9IGJpbm9taWFsKVxuXG5jdi5lcnJvci5mbGV4W2ldIDwtIFxuICBjdi5nbG0oZGZfbWF0Y2hlc190cmFpbixcbiAgICAgICAgIGdsbS5maXQzLmZsZXgsXG4gICAgICAgICBLID0gMTApJGRlbHRhWzFdXG59XG5gYGAifQ== -->

```r

set.seed(17)

cv.error.flex <- rep(0, 7)

for (i in 1:7) {

glm.fit3.flex<- glm(Result ~ Surface + WRUlt3Meses + WRRivalUlt3Meses +
                       PartidosUlt3Meses + PartidosRivalUlt3Meses + poly(WRUltMes, i) + 
                       poly(WRRivalUltMes, i) + poly(PartidosUltMes, i) +
                       poly(PartidosRivalUltMes, i) +
                       WRUlt6Meses + WRRivalUlt6Meses + PartidosUlt6Meses +
                       PartidosRivalUlt6Meses + Round + BestOf,
                     data = df_matches_train,
                     family = binomial)

cv.error.flex[i] <- 
  cv.glm(df_matches_train,
         glm.fit3.flex,
         K = 10)$delta[1]
}
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkZ2xtLmZpdDogZml0dGVkIHByb2JhYmlsaXRpZXMgbnVtZXJpY2FsbHkgMCBvciAxIG9jY3VycmVkXG4ifQ== -->

```
glm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurredglm.fit: fitted probabilities numerically 0 or 1 occurred
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuY3YuZXJyb3IuZmxleCAlPD4lXG4gIGFzX3RpYmJsZSgpICU+JSBcbiAgbXV0YXRlKEZsZXhQb2wgPSBzZXEoMTo3KSkgJT4lIFxuICByZW5hbWUoY3YuZXJyb3IgPSB2YWx1ZSlcblxuY3YuZXJyb3IuZmxleCAlPiUgXG4gIGdncGxvdChhZXMoeCA9IEZsZXhQb2wsIHkgPSBjdi5lcnJvcikpICsgXG4gIGdlb21fbGluZSgpICsgXG4gIGdlb21fcG9pbnQoKSArIFxuICBzY2FsZV94X2NvbnRpbnVvdXMobi5icmVha3MgPSA3KVxuYGBgIn0= -->

```r
cv.error.flex %<>%
  as_tibble() %>% 
  mutate(FlexPol = seq(1:7)) %>% 
  rename(cv.error = value)

cv.error.flex %>% 
  ggplot(aes(x = FlexPol, y = cv.error)) + 
  geom_line() + 
  geom_point() + 
  scale_x_continuous(n.breaks = 7)
```

<!-- rnb-source-end -->

<!-- rnb-plot-begin eyJoZWlnaHQiOjQzMi42MzI5LCJ3aWR0aCI6NzAwLCJzaXplX2JlaGF2aW9yIjowLCJjb25kaXRpb25zIjpbXX0= -->

<img src="data:image/png;base64,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" />

<!-- rnb-plot-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuXG4jTm8gaGF5IHN1ZmljaWVudGUgZXZpZGVuY2lhIGRlIHF1ZSBjb252ZW5nYSBmbGV4aWJpbGl6YXJcblxuZ2xtLnNlbGVjdGVkIDwtIGdsbS5maXQzXG5cbnN1bW1hcnkoZ2xtLnNlbGVjdGVkKVxuYGBgIn0= -->

```r

#No hay suficiente evidencia de que convenga flexibilizar

glm.selected <- glm.fit3

summary(glm.selected)
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiXG5DYWxsOlxuZ2xtKGZvcm11bGEgPSBSZXN1bHQgfiBTdXJmYWNlICsgV1JVbHQzTWVzZXMgKyBXUlJpdmFsVWx0M01lc2VzICsgXG4gICAgUGFydGlkb3NVbHQzTWVzZXMgKyBQYXJ0aWRvc1JpdmFsVWx0M01lc2VzICsgV1JVbHRNZXMgKyBXUlJpdmFsVWx0TWVzICsgXG4gICAgUGFydGlkb3NVbHRNZXMgKyBQYXJ0aWRvc1JpdmFsVWx0TWVzICsgV1JVbHQ2TWVzZXMgKyBXUlJpdmFsVWx0Nk1lc2VzICsgXG4gICAgUGFydGlkb3NVbHQ2TWVzZXMgKyBQYXJ0aWRvc1JpdmFsVWx0Nk1lc2VzICsgUm91bmQgKyBCZXN0T2YsIFxuICAgIGZhbWlseSA9IGJpbm9taWFsLCBkYXRhID0gZGZfbWF0Y2hlc190cmFpbilcblxuRGV2aWFuY2UgUmVzaWR1YWxzOiBcbiAgICBNaW4gICAgICAgMVEgICBNZWRpYW4gICAgICAgM1EgICAgICBNYXggIFxuLTMuNTY2OCAgIDAuMDAxOSAgIDAuMDMwNiAgIDAuMTQ0NCAgIDIuNjIxMSAgXG5cbkNvZWZmaWNpZW50czpcbiAgICAgICAgICAgICAgICAgICAgICAgIEVzdGltYXRlIFN0ZC4gRXJyb3IgeiB2YWx1ZSAgICAgICAgICAgIFByKD58enwpICAgIFxuKEludGVyY2VwdCkgICAgICAgICAgICAgLTEuNjEyOTEgICAgMi45ODg2MyAgLTAuNTQwICAgICAgICAgICAgMC41ODk0MTYgICAgXG5TdXJmYWNlQ2xheSAgICAgICAgICAgICAgMi4wNTM1MCAgICAxLjU0OTQ2ICAgMS4zMjUgICAgICAgICAgICAwLjE4NTA3MSAgICBcblN1cmZhY2VHcmFzcyAgICAgICAgICAgIC0wLjY0ODI0ICAgIDEuNjY0MTQgIC0wLjM5MCAgICAgICAgICAgIDAuNjk2ODgwICAgIFxuU3VyZmFjZUhhcmQgICAgICAgICAgICAgIDAuMzYzMDcgICAgMS40MzU3MCAgIDAuMjUzICAgICAgICAgICAgMC44MDAzNTggICAgXG5XUlVsdDNNZXNlcyAgICAgICAgICAgICAgOS43NjA3OCAgICA1LjA3OTY5ICAgMS45MjIgICAgICAgICAgICAwLjA1NDY2NSAuICBcbldSUml2YWxVbHQzTWVzZXMgICAgICAgIC0zLjE1MzUzICAgIDMuNDA3NDQgIC0wLjkyNSAgICAgICAgICAgIDAuMzU0NzE2ICAgIFxuUGFydGlkb3NVbHQzTWVzZXMgICAgICAgLTAuMTAzNjggICAgMC4wNTc5MSAgLTEuNzkxICAgICAgICAgICAgMC4wNzMzNjcgLiAgXG5QYXJ0aWRvc1JpdmFsVWx0M01lc2VzICAgMC4wNjE1NSAgICAwLjA1NjY4ICAgMS4wODYgICAgICAgICAgICAwLjI3NzU4MyAgICBcbldSVWx0TWVzICAgICAgICAgICAgICAgIDIzLjg2MzI4ICAgIDMuMDUyNTAgICA3LjgxOCAwLjAwMDAwMDAwMDAwMDAwNTM4ICoqKlxuV1JSaXZhbFVsdE1lcyAgICAgICAgICAtMjQuNDg5MjIgICAgMy4wODEwMyAgLTcuOTQ4IDAuMDAwMDAwMDAwMDAwMDAxODkgKioqXG5QYXJ0aWRvc1VsdE1lcyAgICAgICAgICAtMC4zNTAxOSAgICAwLjA4NTIyICAtNC4xMDkgMC4wMDAwMzk3MTEyOTQ1NjI5MyAqKipcblBhcnRpZG9zUml2YWxVbHRNZXMgICAgICAwLjE5NjE5ICAgIDAuMDg0OTIgICAyLjMxMCAgICAgICAgICAgIDAuMDIwODczICogIFxuV1JVbHQ2TWVzZXMgICAgICAgICAgICAtMTIuMDQ3MzggICAgNC42NjA0OSAgLTIuNTg1ICAgICAgICAgICAgMC4wMDk3MzggKiogXG5XUlJpdmFsVWx0Nk1lc2VzICAgICAgICAgMi41MjA1NiAgICAzLjM0MTUyICAgMC43NTQgICAgICAgICAgICAwLjQ1MDY2MCAgICBcblBhcnRpZG9zVWx0Nk1lc2VzICAgICAgICAwLjAzOTE2ICAgIDAuMDI5MzkgICAxLjMzMyAgICAgICAgICAgIDAuMTgyNjE1ICAgIFxuUGFydGlkb3NSaXZhbFVsdDZNZXNlcyAgLTAuMDM3NDMgICAgMC4wMzQzNSAgLTEuMDkwICAgICAgICAgICAgMC4yNzU4MTIgICAgXG5Sb3VuZDJuZCBSb3VuZCAgICAgICAgICAgMy42MjczNyAgICAwLjk4Mzk1ICAgMy42ODcgICAgICAgICAgICAwLjAwMDIyNyAqKipcblJvdW5kM3JkIFJvdW5kICAgICAgICAgICA0LjAxNjY4ICAgIDAuOTk2ODEgICA0LjAzMCAwLjAwMDA1NTg4OTQyODM3NzE2ICoqKlxuUm91bmQ0dGggUm91bmQgICAgICAgICAgIDUuOTczMzEgICAgMS4yODMyOCAgIDQuNjU1IDAuMDAwMDAzMjQ0NDc3NjQzNzMgKioqXG5Sb3VuZFF1YXJ0ZXJmaW5hbHMgICAgICAgNS4xODcwNiAgICAxLjEwNTA5ICAgNC42OTQgMC4wMDAwMDI2ODE2NTMzNTE5NiAqKipcblJvdW5kUm91bmQgUm9iaW4gICAgICAgICA1LjMwOTIxICAgIDEuNDA3NzggICAzLjc3MSAgICAgICAgICAgIDAuMDAwMTYyICoqKlxuUm91bmRTZW1pZmluYWxzICAgICAgICAgIDUuMjkwMjYgICAgMS4xNTAwOSAgIDQuNjAwIDAuMDAwMDA0MjI3NzM4ODYzMjcgKioqXG5Sb3VuZFRoZSBGaW5hbCAgICAgICAgICAgNS45OTU2MSAgICAxLjMwMjUwICAgNC42MDMgMC4wMDAwMDQxNjEwNzczMDE2NyAqKipcbkJlc3RPZjUgICAgICAgICAgICAgICAgICAxLjYwNDgyICAgIDAuNDc5NjIgICAzLjM0NiAgICAgICAgICAgIDAuMDAwODIwICoqKlxuLS0tXG5TaWduaWYuIGNvZGVzOiAgMCDigJgqKirigJkgMC4wMDEg4oCYKirigJkgMC4wMSDigJgq4oCZIDAuMDUg4oCYLuKAmSAwLjEg4oCYIOKAmSAxXG5cbihEaXNwZXJzaW9uIHBhcmFtZXRlciBmb3IgYmlub21pYWwgZmFtaWx5IHRha2VuIHRvIGJlIDEpXG5cbiAgICBOdWxsIGRldmlhbmNlOiA5MDAuOTcgIG9uIDEwMjMgIGRlZ3JlZXMgb2YgZnJlZWRvbVxuUmVzaWR1YWwgZGV2aWFuY2U6IDIzNS4yMSAgb24gMTAwMCAgZGVncmVlcyBvZiBmcmVlZG9tXG5BSUM6IDI4My4yMVxuXG5OdW1iZXIgb2YgRmlzaGVyIFNjb3JpbmcgaXRlcmF0aW9uczogOFxuIn0= -->

```

Call:
glm(formula = Result ~ Surface + WRUlt3Meses + WRRivalUlt3Meses + 
    PartidosUlt3Meses + PartidosRivalUlt3Meses + WRUltMes + WRRivalUltMes + 
    PartidosUltMes + PartidosRivalUltMes + WRUlt6Meses + WRRivalUlt6Meses + 
    PartidosUlt6Meses + PartidosRivalUlt6Meses + Round + BestOf, 
    family = binomial, data = df_matches_train)

Deviance Residuals: 
    Min       1Q   Median       3Q      Max  
-3.5668   0.0019   0.0306   0.1444   2.6211  

Coefficients:
                        Estimate Std. Error z value            Pr(>|z|)    
(Intercept)             -1.61291    2.98863  -0.540            0.589416    
SurfaceClay              2.05350    1.54946   1.325            0.185071    
SurfaceGrass            -0.64824    1.66414  -0.390            0.696880    
SurfaceHard              0.36307    1.43570   0.253            0.800358    
WRUlt3Meses              9.76078    5.07969   1.922            0.054665 .  
WRRivalUlt3Meses        -3.15353    3.40744  -0.925            0.354716    
PartidosUlt3Meses       -0.10368    0.05791  -1.791            0.073367 .  
PartidosRivalUlt3Meses   0.06155    0.05668   1.086            0.277583    
WRUltMes                23.86328    3.05250   7.818 0.00000000000000538 ***
WRRivalUltMes          -24.48922    3.08103  -7.948 0.00000000000000189 ***
PartidosUltMes          -0.35019    0.08522  -4.109 0.00003971129456293 ***
PartidosRivalUltMes      0.19619    0.08492   2.310            0.020873 *  
WRUlt6Meses            -12.04738    4.66049  -2.585            0.009738 ** 
WRRivalUlt6Meses         2.52056    3.34152   0.754            0.450660    
PartidosUlt6Meses        0.03916    0.02939   1.333            0.182615    
PartidosRivalUlt6Meses  -0.03743    0.03435  -1.090            0.275812    
Round2nd Round           3.62737    0.98395   3.687            0.000227 ***
Round3rd Round           4.01668    0.99681   4.030 0.00005588942837716 ***
Round4th Round           5.97331    1.28328   4.655 0.00000324447764373 ***
RoundQuarterfinals       5.18706    1.10509   4.694 0.00000268165335196 ***
RoundRound Robin         5.30921    1.40778   3.771            0.000162 ***
RoundSemifinals          5.29026    1.15009   4.600 0.00000422773886327 ***
RoundThe Final           5.99561    1.30250   4.603 0.00000416107730167 ***
BestOf5                  1.60482    0.47962   3.346            0.000820 ***
---
Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

(Dispersion parameter for binomial family taken to be 1)

    Null deviance: 900.97  on 1023  degrees of freedom
Residual deviance: 235.21  on 1000  degrees of freedom
AIC: 283.21

Number of Fisher Scoring iterations: 8
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuZ2xtLnNlbGVjdGVkLnByb2JzIDwtIHByZWRpY3QoZ2xtLnNlbGVjdGVkLCBkZl9tYXRjaGVzX3Rlc3QsXG4gICAgICAgICAgICAgICAgICAgICAgdHlwZSA9IFwicmVzcG9uc2VcIilcblxuZ2xtLnNlbGVjdGVkLnByZWQgPC0gcmVwKFwiTG9zZVwiLCBucm93KGRmX21hdGNoZXNfdGVzdCkpXG5nbG0uc2VsZWN0ZWQucHJlZFtnbG0uc2VsZWN0ZWQucHJvYnMgPiAwLjU1XSA9IFwiV2luXCJcblxudGFibGUoZ2xtLnNlbGVjdGVkLnByZWQsIGRmX21hdGNoZXNfdGVzdCRSZXN1bHQpXG5gYGAifQ== -->

```r
glm.selected.probs <- predict(glm.selected, df_matches_test,
                      type = "response")

glm.selected.pred <- rep("Lose", nrow(df_matches_test))
glm.selected.pred[glm.selected.probs > 0.55] = "Win"

table(glm.selected.pred, df_matches_test$Result)
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiICAgICAgICAgICAgICAgICBcbmdsbS5zZWxlY3RlZC5wcmVkIExvc2UgV2luXG4gICAgICAgICAgICAgTG9zZSAgICA1ICAgMFxuICAgICAgICAgICAgIFdpbiAgICAgMyAgNDFcbiJ9 -->

```
                 
glm.selected.pred Lose Win
             Lose    5   0
             Win     3  41
```



<!-- rnb-output-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->



Ahora determino la tasa de corte optima para determinar la prediccion del resultado.



<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-frame-begin eyJtZXRhZGF0YSI6eyJjbGFzc2VzIjpbInRibF9kZiIsInRibCIsImRhdGEuZnJhbWUiXSwibnJvdyI6MTksIm5jb2wiOjEwLCJzdW1tYXJ5Ijp7IkEgdGliYmxlIjpbIjE5IHggMTAiXX19LCJyZGYiOiJINHNJQUFBQUFBQUFCZ3R5aVREbWl1QmlZR0JnWm1CaEJKS3NRQ1lEbTNPQW9aR3BFUU1EQ3hPUXg4akF3c0FKb2l1QThzSkFCa2c1SHhBTE80Z3dnTUZnbzJIdVk2QXpjSURSSFBocEJsajRFVkJITXhyZHZWRGEvZ09hKzF3YUlQTDBvcDFoTkFOZUd1WSsreHRRZDlPYnZ1U3BNZ21JTU9pam9XQUFkOThIcUhwNjBlOEtrcCt6MlJYWXYxMHg5VlpuN0VwY05OeDlUNkQ2NkUwL3U1Mjc3WGJ1ZGd6NjFTb1FXTTB3Vk1MdkhWZlJoK0RwelhTajMrd1JlZnBndWI3OUcwZzRZZEJ2M2M3OTZwMzdGZTYrbFROQllKYjlUaWg5MkJnRVRPeFBRdmtYb1A2K0RCWTN0citXQmdMcDlqZWg4bmZPZ01CWit3ZFFkUStoNG8raDVqd0J5NSt6ZndiVjl3S3NqTkgrSlZUZGE2aTZOMUIxNzhEcTB0QXFGdGE4eE56VVlpQkRnQUZVdVVBRW1VTDhZQ3czQkNzQUxndGpDYm9sNWhTbkJ1UVhaNVprbHFVR0paYWtRaVVFUW9wS3NZbHpCNmZtZ1FVelN5cmhRZ1dweVpscG1ja0lJUTdINU9UU29zUmtHSjh6SktNb3RUZ2pQeWNGemZHY1JmbmxlakFQOElLYzFnQWsvdi8vL3hiZGw4azVpY1V3WDhJRXVWSVNTeEwxMG9xQStvRzhmMmhhMlBNTFNqTHo4NENhbUVCMUdTdWFac1lpTkFIT2tzU2tuTlQ0SUg5bkJrZ3R6UWlKTjdDN1FHeGhKRFlYeERLbS8xQkRXS0dHc0tYbXBXZm13VUtMTlNjeEtUVUh5dUVEK2hYc1ZiMkNvc3k4RXBnZmdLTEZlaVg1Sllrd2RWekorVGt3RWJDdkdQNEJBRW1iaFBScENBQUEifQ== -->

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["TN"],"name":[1],"type":["dbl"],"align":["right"]},{"label":["FN"],"name":[2],"type":["dbl"],"align":["right"]},{"label":["FP"],"name":[3],"type":["dbl"],"align":["right"]},{"label":["TP"],"name":[4],"type":["dbl"],"align":["right"]},{"label":["FalsePositiveRate"],"name":[5],"type":["dbl"],"align":["right"]},{"label":["TruePositiveRate"],"name":[6],"type":["dbl"],"align":["right"]},{"label":["Sensitivity"],"name":[7],"type":["dbl"],"align":["right"]},{"label":["Specificity"],"name":[8],"type":["dbl"],"align":["right"]},{"label":["Accuracy"],"name":[9],"type":["dbl"],"align":["right"]},{"label":["Threshold"],"name":[10],"type":["dbl"],"align":["right"]}],"data":[{"1":"5","2":"0","3":"3","4":"41","5":"0.3750000","6":"1.0000000","7":"0.6250000","8":"1.0000000","9":"0.9387755","10":"0.05"},{"1":"5","2":"0","3":"3","4":"41","5":"0.3750000","6":"1.0000000","7":"0.6250000","8":"1.0000000","9":"0.9387755","10":"0.10"},{"1":"5","2":"0","3":"3","4":"41","5":"0.3750000","6":"1.0000000","7":"0.6250000","8":"1.0000000","9":"0.9387755","10":"0.15"},{"1":"5","2":"0","3":"3","4":"41","5":"0.3750000","6":"1.0000000","7":"0.6250000","8":"1.0000000","9":"0.9387755","10":"0.20"},{"1":"5","2":"0","3":"3","4":"41","5":"0.3750000","6":"1.0000000","7":"0.6250000","8":"1.0000000","9":"0.9387755","10":"0.25"},{"1":"5","2":"0","3":"3","4":"41","5":"0.3750000","6":"1.0000000","7":"0.6250000","8":"1.0000000","9":"0.9387755","10":"0.30"},{"1":"5","2":"0","3":"3","4":"41","5":"0.3750000","6":"1.0000000","7":"0.6250000","8":"1.0000000","9":"0.9387755","10":"0.35"},{"1":"5","2":"0","3":"3","4":"41","5":"0.3750000","6":"1.0000000","7":"0.6250000","8":"1.0000000","9":"0.9387755","10":"0.40"},{"1":"5","2":"0","3":"3","4":"41","5":"0.3750000","6":"1.0000000","7":"0.6250000","8":"1.0000000","9":"0.9387755","10":"0.45"},{"1":"5","2":"0","3":"3","4":"41","5":"0.3750000","6":"1.0000000","7":"0.6250000","8":"1.0000000","9":"0.9387755","10":"0.50"},{"1":"5","2":"0","3":"3","4":"41","5":"0.3750000","6":"1.0000000","7":"0.6250000","8":"1.0000000","9":"0.9387755","10":"0.55"},{"1":"5","2":"0","3":"3","4":"41","5":"0.3750000","6":"1.0000000","7":"0.6250000","8":"1.0000000","9":"0.9387755","10":"0.60"},{"1":"5","2":"0","3":"3","4":"41","5":"0.3750000","6":"1.0000000","7":"0.6250000","8":"1.0000000","9":"0.9387755","10":"0.65"},{"1":"5","2":"0","3":"3","4":"41","5":"0.3750000","6":"1.0000000","7":"0.6250000","8":"1.0000000","9":"0.9387755","10":"0.70"},{"1":"5","2":"2","3":"3","4":"39","5":"0.3750000","6":"0.9512195","7":"0.6250000","8":"0.9512195","9":"0.8979592","10":"0.75"},{"1":"5","2":"3","3":"2","4":"38","5":"0.2857143","6":"0.9268293","7":"0.7142857","8":"0.9268293","9":"0.8958333","10":"0.80"},{"1":"5","2":"3","3":"2","4":"38","5":"0.2857143","6":"0.9268293","7":"0.7142857","8":"0.9268293","9":"0.8958333","10":"0.85"},{"1":"5","2":"3","3":"2","4":"38","5":"0.2857143","6":"0.9268293","7":"0.7142857","8":"0.9268293","9":"0.8958333","10":"0.90"},{"1":"5","2":"3","3":"1","4":"38","5":"0.1666667","6":"0.9268293","7":"0.8333333","8":"0.9268293","9":"0.9148936","10":"0.95"}],"options":{"columns":{"min":{},"max":[10],"total":[10]},"rows":{"min":[10],"max":[10],"total":[19]},"pages":{}}}
  </script>
</div>

<!-- rnb-frame-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->



#Redes Neuronales

Ahora, encararemos el mismo problema utilizando redes neuronales. La idea es encontrar un modelo que permita identificar de la forma mas precisa posible los partidos en los que Nadal tiene una alta chance de perder.



<!-- rnb-text-end -->

