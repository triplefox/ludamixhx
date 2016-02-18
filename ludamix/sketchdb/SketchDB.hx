import haxe.Serializer;
import haxe.Unserializer;
import Type;

class DBCell {

	public var i : Null<Int>;
	public var f : Null<Float>;
	public var s : String;

	public function new() {}
	public static function int(v) {var r = new DBCell(); r.i = v; return r;}
	public static function float(v) {var r = new DBCell(); r.f = v; return r;}
	public static function string(v) {var r = new DBCell(); r.s = v; return r;}
	public function toString() {
		if (s != null) return s;
		else if (f != null) return Std.string(f);
		else return Std.string(i);
	}
	public function equals(c : DBCell) {
		return i == c.i && f == c.f && s == c.s;
	}

}

abstract RowRef(Int) {
	public inline function new(i) {this = i;}
	public inline function asInt() : Int {return this;}
	public inline function deref(db : SketchDB) : Map<String, DBCell> {
		var r = new Map();
		for (cn in db.table.get(db.row[this])) {
			r.set(cn, db.column.get(cn).get(this));
		}
		return r;
	}
}

class SketchDB {

	public var table = new Map<String, Array<String>>(); // DB schema
	public var column = new Map<String, Map<Int, DBCell>>(); // all cols in DB
	public var row = new Array<String>(); // all rows in DB

	public function new() {}
	public inline function columnName(t, c) { return '${t}.${c}'; }
	public inline function allocColumn(t : String, c : String) {
		var cn = columnName(t, c);
		if (!column.exists(cn)) {
			if (!table.exists(t)) table.set(t, new Array());
			var td = table.get(t);
			td.push(cn);
			column.set(cn, new Map());
		}
	}
	public inline function allocRows(t : String, colname : Array<String>, rows : Array<Array<DBCell>>) {
		if (!table.exists(t)) throw 'allocRows: table $t not found';
		var ti = table.get(t);
		var cnmap = new Map<String, Int>();
		for (i in 0...colname.length) {
			var cn = columnName(t, colname[i]);
			cnmap.set(cn, i);
			if (!column.exists(cn)) throw 'allocRows: $cn not in schema';
		}
		for (schemacn in ti) {
			if (!cnmap.exists(schemacn)) 
				throw 'allocRows: requires ${schemacn}';
		}
		for (r in rows) {
			var rowid = row.length;
			var nr = row.push(t);
			for (cn in cnmap.keys()) {
				column.get(cn).set(rowid, r[cnmap.get(cn)]);
			}
		}
	}
	public inline function getColumnRows(cn : String) : Array<RowRef> {
		return [for (n in column.get(cn).keys()) new RowRef(n)];
	}
	public inline function filter(cn : String, cur : Array<RowRef>, fn : DBCell->Bool) : Array<RowRef> {
		var col = column.get(cn);
		var result = new Array<RowRef>();
		for (r in cur) {
			if (col.exists(r.asInt()) && fn(col.get(r.asInt()))) result.push(r);
		}
		return result;
	}
	// given a list of columns and a list of rows to search within each column,
	// find all rows whose columns are equal
	public inline function intersectString(colnames : Array<String>, cur : Array<Array<RowRef>>) : 
		Array<Array<RowRef>> {
		if (colnames.length != cur.length) throw '$colnames intersection has mismatched input shape';
		var work = new Array<Array<RowRef>>();
		var workval = new Array<Array<String>>();
		// find the rows among the ones specified in each column that are valid;
		// extract the values of each row
		for (colidx in 0...cur.length) {
			var colrange = cur[colidx];
			var cname = colnames[colidx];
			if (!column.exists(cname)) throw 'couldn\'t find column $cname';
			var col = this.column.get(cname);
			var nrow = new Array<RowRef>();
			var nval = new Array<String>();
			for (row in colrange) {
				if (col.exists(row.asInt()))
				{
					nrow.push(row);
					nval.push(col.get(row.asInt()).s);
				}
			}
			work[colidx] = nrow;
			workval[colidx] = nval;
		}
		// early outs: if it's impossible to return values
		var early = false;
		if (work.length < 1)
			early = true;
		for (n in 0...work.length) {
			if (work[n].length < 1)
				early = true;
			if (workval[n][0] == null)
				throw 'column ${colnames[n]} is not a string column';
		}
		if (early) return [];
		else {
			// now we proceed to find one-to-many equalities in each column.
			var stack = [0];
			var result = new Array<Array<RowRef>>();
			stack.push(0);
			while (stack.length > 0) {
				var value0 = workval[0][stack[0]];
				var s_col = stack.length - 1;
				var value1 = workval[s_col][stack[s_col]];
				if (value0 == value1) {
					if (stack.length < work.length) { // true, push
						stack.push(0);
					}
					else { // all columns true, commit and continue
						result.push([for (n in 0...stack.length) work[n][stack[n]]]);
						stack[s_col] += 1;
					}
				} else { // false, continue
					stack[s_col] += 1;					
				}
				while (stack[s_col] >= work[s_col].length) { // pop stack (and continue)
					stack.pop();
					s_col = stack.length - 1;
					if (stack.length > 0)
						stack[s_col] += 1;
					else
						break;
				}
			}
			return result;
		}
	}
	public inline function intersectInt(colnames : Array<String>, cur : Array<Array<RowRef>>) : 
		Array<Array<RowRef>> {
		if (colnames.length != cur.length) throw '$colnames intersection has mismatched input shape';
		var work = new Array<Array<RowRef>>();
		var workval = new Array<Array<Int>>();
		// find the rows among the ones specified in each column that are valid;
		// extract the values of each row
		for (colidx in 0...cur.length) {
			var colrange = cur[colidx];
			var cname = colnames[colidx];
			if (!column.exists(cname)) throw 'couldn\'t find column $cname';
			var col = this.column.get(cname);
			var nrow = new Array<RowRef>();
			var nval = new Array<Int>();
			for (row in colrange) {
				if (col.exists(row.asInt()))
				{
					nrow.push(row);
					nval.push(col.get(row.asInt()).i);
				}
			}
			work[colidx] = nrow;
			workval[colidx] = nval;
		}
		// early outs: if it's impossible to return values
		var early = false;
		if (work.length < 1)
			early = true;
		for (n in 0...work.length) {
			if (work[n].length < 1)
				early = true;
			if (workval[n][0] == null)
				throw 'column ${colnames[n]} is not a int column';
		}
		if (early) return [];
		else {
			// now we proceed to find one-to-many equalities in each column.
			var stack = [0];
			var result = new Array<Array<RowRef>>();
			stack.push(0);
			while (stack.length > 0) {
				var value0 = workval[0][stack[0]];
				var s_col = stack.length - 1;
				var value1 = workval[s_col][stack[s_col]];
				if (value0 == value1) {
					if (stack.length < work.length) { // true, push
						stack.push(0);
					}
					else { // all columns true, commit and continue
						result.push([for (n in 0...stack.length) work[n][stack[n]]]);
						stack[s_col] += 1;
					}
				} else { // false, continue
					stack[s_col] += 1;					
				}
				while (stack[s_col] >= work[s_col].length) { // pop stack (and continue)
					stack.pop();
					s_col = stack.length - 1;
					if (stack.length > 0)
						stack[s_col] += 1;
					else
						break;
				}
			}
			return result;
		}
	}
	public function remove(rows : Array<RowRef>) {
		for (rowref in rows) {
			var idx = rowref.asInt();
			if (row[idx] != null) {
				var tab = table.get(row[idx]);
				for (cname in tab) {
					column.get(cname).remove(idx);
				}
				row[idx] = null;
			}
		}
	}
	public inline function compact() {
		var nrow = new Array<String>();
		var ncolumn = new Map<String, Map<Int, DBCell>>();
		for (idx in 0...row.length) {
			var tab = row[idx];
			if (tab != null) {
				var cell = row[idx];
				var id = nrow.length;
				for (cn in table.get(tab)) {
					if (!ncolumn.exists(cn)) 
						ncolumn.set(cn, new Map<Int, DBCell>());
					ncolumn.get(cn).set(id, column.get(cn).get(idx));
				}
				nrow.push(tab);
			}
		}
		row = nrow;
		column = ncolumn;
	}
	
	public function xml() : Xml {
		var x = Xml.createElement("sketchdb");
		for (t in table.keys()) {
			var xt = Xml.createElement("table");
			xt.set("i", t);
			x.addChild(xt);
			for (c in table.get(t)) {
				var xc = Xml.createElement("column");
				xc.set("i", c);
				xt.addChild(xc);
				var col = column.get(c);
				for (id in col.keys()) {
					var xr = Xml.createElement("cell");
					xr.set("i", Std.string(id));
					var serial : String;
					var cell = col.get(id);
					if (cell.s != null) serial = Serializer.run(cell.s);
					else if (cell.f != null) serial = Serializer.run(cell.f);
					else serial = Serializer.run(cell.i);
					xr.addChild(Xml.createPCData(serial));
					xc.addChild(xr);
				}
			}
		}
		for (r in 0...row.length) {
			var xr = Xml.createElement("row");
			xr.set("i", Std.string(r));
			xr.addChild(Xml.createPCData(row[r]));
			x.addChild(xr);
		}
		return x;
	}
	public static function fromXml(x: Xml) : SketchDB {
		var db = new SketchDB();
		if (x.nodeName == "sketchdb") {
			for (n in x.elements()) {
				if (n.nodeName == "row") {
					db.row[Std.parseInt(n.get("i"))] = n.firstChild().nodeValue;
				}
				else if (n.nodeName == "table") {
					var xt = n;
					for (i in xt.elements()) {
						if (i.nodeName == "column") {
							var xc = i;
							var cn = xc.get("i");
							var delimiter = cn.indexOf(".");
							var tabn = cn.substr(0, delimiter);
							var coln = cn.substr(delimiter + 1);
							db.allocColumn(tabn, coln);
							for (j in xc.elements()) {
								if (j.nodeName == "cell") {
									var cell = new DBCell();
									var id = Std.parseInt(j.get("i"));
									var d : Dynamic = Unserializer.run(j.firstChild().nodeValue);
									if (Type.typeof(d) == TInt)
										cell.i = d;
									else if (Type.typeof(d) == TFloat)
										cell.f = d;
									else
										cell.s = d;
									db.column.get(cn).set(id, cell);
								}
							}
						}
					}
				}
			}
		}
		return db;
	}

}

