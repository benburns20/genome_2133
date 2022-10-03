import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

List selections = [];

class VariantView extends StatefulWidget {
  final String country;

  const VariantView({Key? key, required this.country}) : super(key: key);

  @override
  State<VariantView> createState() => _VariantView();
}

class _VariantView extends State<VariantView> {
  @override
  Widget build(BuildContext context)  {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, //change your color here
        ),
        title: Text(widget.country + " Variants", style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 50),
                  child: IconButton(
                    icon: const Icon(Icons.content_copy),
                    tooltip: "Copy selected variants to clipboard",
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: selections.toString().replaceAll("[", '').replaceAll("]", ''))).then((_){
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text('Copied variants to clipboard')));
                      });
                    },
                  )
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: ElevatedButton(
                      style: TextButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 20),
                      ),   //style
                      onPressed: () => launchUrl(Uri.parse('https://blast.ncbi.nlm.nih.gov/Blast.cgi?PROGRAM=blastn&PAGE_TYPE=BlastSearch&LINK_LOC=blasthome')),
                    child: const Text('Compare')
                  )
                )

              ]
            ),
          ),
          //add Compare button right here
        ],
      ),
      body: const SortablePage(),
    );
  }
}

class SortablePage extends StatefulWidget {
  const SortablePage({Key? key}) : super(key: key);

  @override
  _SortablePageState createState() => _SortablePageState();
}


class _SortablePageState extends State<SortablePage> {
  List<String> headerLabel = ['accession', 'geographical location', 'date collected', 'generated', 'pinned'];
  List users = [
    {
      "accession": "NC_045512",
      "geographical location": "China",
      "date collected": 2019,
      "generated": false,
      "pinned": false
    },
    {
      "accession": "L00000001",
      "geographical location": "China",
      "date collected": 2019,
      "generated": true,
      "pinned": false
    },
    {
      "accession": "NC_045512",
      "geographical location": "China",
      "date collected": 2019,
      "generated": false,
      "pinned": false
    },
    {
      "accession": "MN938384",
      "geographical location": "China: Shenzhen",
      "date collected": 2020,
      "generated": false,
      "pinned": false
    },
    {
      "accession": "L00000002",
      "geographical location": "China",
      "date collected": 2020,
      "generated": true,
      "pinned": false
    },
    {
      "accession": "MN938384",
      "geographical location": "China: Shenzhen",
      "date collected": 2020,
      "generated": false,
      "pinned": false
    },
    {
      "accession": "MT027063",
      "geographical location": "USA: CA",
      "date collected": 2020,
      "generated": false,
      "pinned": false
    },
    {
      "accession": "L00000003",
      "geographical location": "China",
      "date collected": 2022,
      "generated": true,
      "pinned": false
    },
    {
      "accession": "ON247308",
      "geographical location": "USA: CA",
      "date collected": 2020,
      "generated": false,
      "pinned": false
    },
    {
      "accession": "L00000003",
      "geographical location": "China",
      "date collected": 2021,
      "generated": true,
      "pinned": false
    },
    {
      "accession": "ON247308",
      "geographical location": "USA: MS",
      "date collected": 2022,
      "generated": false,
      "pinned": false
    }
  ];
  int? sortColumnIndex;
  bool isAscending = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        Container(color: Theme.of(context).backgroundColor),
        Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                child: buildDataTable(),
              ),
            )
        ),
      ],
    ),
  );

  Widget buildDataTable() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: DataTable(
        showCheckboxColumn: true,
        sortAscending: isAscending,
        sortColumnIndex: sortColumnIndex,
        columns: getColumns(headerLabel),
        rows: getRows(users),
      ),
    );
    /*return FutureBuilder(
      future: rootBundle.loadString("assets/data.json"),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (!snapshot.hasData) return Container();
        users = json.decode(snapshot.data!)["Fake Data"];
        return DataTable(
          sortAscending: isAscending,
          sortColumnIndex: sortColumnIndex,
          columns: getColumns(['Accession', 'Geographical Location', 'Date Collected', 'Generated', 'Pinned']),
          rows: getRows(users),
        );
      }
    );*/
  }

  List<DataColumn> getColumns(List<String> columns) => columns.map((String column) => DataColumn(
    label: Expanded(child: Text(column.toTitle, textAlign: TextAlign.center)),
    onSort: onSort,
  )).toList();

  List<DataRow> getRows(List users) => users.map((user) {
    onSelectChanged: (bool isSelected) {
      if (isSelected) {
        selections.add(user["accession"]);
      } else {
        selections.remove(user["accession"]);
      }

    };
    List<DataCell> lister = getCells(
        [user["accession"],
          user["geographical location"],
          user["date collected"],
          user["generated"] ? "Yes" : "Actual"]
    );

    lister.add(DataCell(
      Align(
        alignment: Alignment.centerRight,
        child: IconButton(
          icon: user["pinned"] ? const Icon(Icons.push_pin): const Icon(Icons.panorama_fish_eye),
          color: const Color(0xff445756),
          onPressed: () {
            setState(() {
              user["pinned"] = !user["pinned"];
              if (user["pinned"]) {
                selections.add(user["accession"]);
              } else {
                selections.remove(user["accession"]);
              }
            });
          },
        ),
      )
    ));


    return DataRow(cells: lister);
  }).toList();

  List<DataCell> getCells(List<dynamic> cells) =>
      cells.map((data) => DataCell(
          Align(
              alignment: Alignment.centerRight,
              child: Text(data.toString())
          ))
      ).toList();
  void onSort(int columnIndex, bool ascending) {
    users.sort((user1, user2) =>
        compareString(ascending, user1[headerLabel[columnIndex]].toString(), user2[headerLabel[columnIndex]].toString()));

    setState(() {
      sortColumnIndex = columnIndex;
      isAscending = ascending;
    });
  }

  int compareString(bool ascending, String value1, String value2) =>
      ascending ? value1.compareTo(value2) : value2.compareTo(value1);
}

extension StringExtension on String {
  String capitalize() => "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  String get toTitle => split(" ").map((str) => str.capitalize()).join(" ");
}