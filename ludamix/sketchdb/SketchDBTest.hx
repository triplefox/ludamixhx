import SketchDB;

class SketchDBTest {

	public static function main() {
		var db = new SketchDB();
		db.allocColumn('person','name');
		db.allocColumn('person','job');
		db.allocColumn('person','rating');
		db.allocColumn('job','title');
		db.allocColumn('job','salary');
		db.allocColumn('rank','rating');
		db.allocColumn('rank','title');

		db.allocRows('person', ['name','job','rating'], [
			[DBCell.string('Joe Smith'), DBCell.string('Blacksmith'), DBCell.int(1)],
			[DBCell.string('Woody Jones'), DBCell.string('Carpenter'), DBCell.int(1)],
			[DBCell.string('Alice Astar'), DBCell.string('Pathfinder'), DBCell.int(2)],
			[DBCell.string('Beatrice Breadth-first'), DBCell.string('Pathfinder'), DBCell.int(2)]
		]);
		db.allocRows('job', ['title','salary'], [
			[DBCell.string('Blacksmith'), DBCell.int(11025)],
			[DBCell.string('Carpenter'), DBCell.int(22050)],
			[DBCell.string('Pathfinder'), DBCell.int(44100)]
		]);
		db.allocRows('rank', ['title', 'rating'], [
			[DBCell.string('Low'), DBCell.int(1)],
			[DBCell.string('High'), DBCell.int(2)],
		]);

		for (n in db.getColumnRows('person.name')) {
			trace(n.deref(db));
		}
		for (n in db.getColumnRows('job.title')) {
			trace(n.deref(db));
		}
		
		trace('jobs above 15000 salary');
		var r = db.filter('job.salary',db.getColumnRows('job.salary'), function(c) {
			return c.i > 15000;
		});
		for (n in r) trace(n.deref(db));

		trace('people above 15000 salary');
		var rr = db.intersectString(['job.title','person.job'],[r,db.getColumnRows('person.job')]);
		for (r in rr) { trace([for (n in r) n.deref(db)]); }
		
		trace('people\'s ranks');
		var rr = db.intersectInt(['person.rating', 'rank.rating'],
			[db.getColumnRows('person.rating'),db.getColumnRows('rank.rating')]);
		for (r in rr) { trace([for (n in r) n.deref(db)]); }
		
		trace('xml');
		var xml = db.xml();
		trace(xml);
		
		trace('mass add on people');
		var mass_add = new Array<Array<DBCell>>();
		var kind = ['Blacksmith', 'Carpenter', 'Pathfinder'];
		for (i in 0...10000) {
			mass_add.push([DBCell.string('Random Person'), DBCell.string(kind[Std.random(3)]), DBCell.int(Std.random(2))]);
		}
		db.allocRows('person', ['name','job','rating'], mass_add);
		
		trace('mass join on people');
		var rr = db.intersectString(['job.title','person.job'],[db.getColumnRows('job.title'),db.getColumnRows('person.job')]);
		//for (r in rr) { trace([for (n in r) n.deref(db)]); }
		trace('done');
		
		trace('additional jobs');
		var mass_add = new Array<Array<DBCell>>();
		var kind = ['Blacksmith', 'Carpenter', 'Pathfinder'];
		for (i in 0...50) {
			mass_add.push([DBCell.string(kind[Std.random(3)]), DBCell.int(Std.random(150000))]);
		}
		db.allocRows('job', ['title', 'salary'], mass_add);
		
		trace('mass join on people and job');
		var rr = db.intersectString(['job.title','person.job'],[db.getColumnRows('job.title'),db.getColumnRows('person.job')]);
		//for (r in rr) { trace([for (n in r) n.deref(db)]); }
		
		trace('remove the carpenters');
		var carpenters = db.filter('job.title', db.getColumnRows('job.title'), function(c) { return c.s == 'Carpenter'; });
		var rr = db.intersectString(['job.title', 'person.job'], [carpenters, db.getColumnRows('person.job')]);		
		for (n in rr) db.remove(n);
		trace([for (n in db.getColumnRows("person.job")) 
			if (db.column.get("person.job").get(n.asInt()).s == "Carpenter") n.deref(db)]);
		
		trace('xml unserialize');
		var xml = db.xml();
		var db2 = SketchDB.fromXml(xml);
		for (r in 0...db2.row.length) if (db.row[r] != db2.row[r]) throw "row failed";
		for (ki in db2.column.keys()) {
			var col0 = db.column.get(ki);
			var col1 = db2.column.get(ki);
			for (k in col0.keys())
				if (!col0.get(k).equals(col1.get(k)))
					throw "column failed";
		}
		for (t in db2.table.keys()) {
			var t0 = db.table.get(t);
			var t1 = db2.table.get(t);
			for (i in 0...t0.length) {
				if (t0[i] != t1[i]) throw "table failed";
			}
		}
		
		trace('${db.row.length} rows');
		trace('compacting');
		db.compact();
		trace('${db.row.length} rows');
		
		trace('done');
	}

}
