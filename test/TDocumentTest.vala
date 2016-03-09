/* -*- Mode: vala; indent-tabs-mode: t; c-basic-offset: 2; tab-width: 2 -*- */
/* Notation.vala
 *
 * Copyright (C) 2011-2015  Daniel Espinosa <esodan@gmail.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.

 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.

 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Daniel Espinosa <esodan@gmail.com>
 */

using GXml;

class TDocumentTest : GXmlTest {
	public class TTestObject : SerializableObjectModel
	{
		public string name { get; set; }
		public override string node_name () { return "Test"; }
		public override string to_string () { return "TestNode"; }
	}
	public static void add_tests () {
		Test.add_func ("/gxml/t-document", () => {
			try {
				var d = new TDocument ();
				assert (d.name == "#document");
				assert (d.root == null);
				assert (d.children != null);
				assert (d.attrs != null);
				assert (d.children.size == 0);
				assert (d.value == null);
			}
			catch (GLib.Error e) {
#if DEBUG
				GLib.message (@"ERROR: $(e.message)");
#endif
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/t-document/root", () => {
			try {
				var f = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/t-test.xml");
				if (f.query_exists ()) f.delete ();
				var d = new TDocument.for_path (GXmlTestConfig.TEST_SAVE_DIR+"/t-test.xml");
				var e = d.create_element ("root");
				d.children.add (e);
				assert (d.children.size == 1);
				assert (d.root != null);
				assert (d.root.name == "root");
				assert (d.root.value == "");
			}
			catch (GLib.Error e) {
#if DEBUG
				GLib.message (@"ERROR: $(e.message)");
#endif
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/t-document/save/root", () => {
				try {
					var f = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/t-test.xml");
					if (f.query_exists ()) f.delete ();
					var d = new TDocument.for_path (GXmlTestConfig.TEST_SAVE_DIR+"/t-test.xml");
					var e = d.create_element ("root");
					d.children.add (e);
					assert (d.children.size == 1);
					assert (d.root != null);
					assert (d.root.name == "root");
					assert (d.root.value == "");
					GLib.Test.message ("Saving document to: "+f.get_path ());
					assert (d.save ());
					GLib.Test.message ("Reading saved document to: "+f.get_path ());
					assert (f.query_exists ());
					var istream = f.read ();
					var ostream = new MemoryOutputStream.resizable ();
					ostream.splice (istream, 0);
					assert ("<?xml version=\"1.0\"?>" in ((string)ostream.data));
					assert ("<root/>" in ((string)ostream.data));
				}
				catch (GLib.Error e) {
#if DEBUG
					GLib.message (@"ERROR: $(e.message)");
#endif
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/t-document/save/root/attribute", () => {
				try {
					var f = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/t-test.xml");
					if (f.query_exists ()) f.delete ();
					var d = new TDocument.for_path (GXmlTestConfig.TEST_SAVE_DIR+"/t-test.xml");
					var e = d.create_element ("root");
					d.children.add (e);
					assert (d.children.size == 1);
					assert (d.root != null);
					assert (d.root.name == "root");
					assert (d.root.value == "");
					var root = (GXml.Element) d.root;
					root.set_attr ("Pos","on");
					var at1 = root.get_attr ("Pos");
					assert (at1 != null);
					assert (at1.value == "on");
					root.set_attr ("tKm","1000");
					var at2 = root.get_attr ("tKm");
					assert (at2 != null);
					assert (at2.value == "1000");
					d.save ();
					var istream = f.read ();
					uint8[] buffer = new uint8[2048];
					istream.read_all (buffer, null);
					istream.close ();
					assert ("<?xml version=\"1.0\"?>" in ((string)buffer));
					assert ("<root" in ((string)buffer));
					assert ("Pos=\"on\"" in ((string)buffer));
					assert ("tKm=\"1000\"" in ((string)buffer));
				}
				catch (GLib.Error e) {
#if DEBUG
					GLib.message (@"ERROR: $(e.message)");
#endif
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/t-document/save/root/content", () => {
				try {
					var f = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/t-test.xml");
					if (f.query_exists ()) f.delete ();
					var d = new TDocument.for_path (GXmlTestConfig.TEST_SAVE_DIR+"/t-test.xml");
					var e = d.create_element ("root");
					d.children.add (e);
					assert (d.children.size == 1);
					assert (d.root != null);
					assert (d.root.name == "root");
					assert (d.root.value == "");
					var root = (GXml.Element) d.root;
					root.content = "GXml TDocument Test";
					assert (root.children.size == 1);
					assert (root.content == "GXml TDocument Test");
					var t = root.children.get (0);
					assert (t.value == "GXml TDocument Test");
					assert (t is GXml.Text);
					//GLib.message (@"$d");
					d.save ();
					var istream = f.read ();
					uint8[] buffer = new uint8[2048];
					istream.read_all (buffer, null);
					istream.close ();
					assert ("<?xml version=\"1.0\"?>" in ((string)buffer));
					assert ("<root" in ((string)buffer));
					assert (">GXml TDocument Test<" in ((string)buffer));
				}
				catch (GLib.Error e) {
#if DEBUG
					GLib.message (@"ERROR: $(e.message)");
#endif
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/t-document/save/root/children", () => {
				try {
					var f = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/t-test.xml");
					if (f.query_exists ()) f.delete ();
					var d = new TDocument.for_path (GXmlTestConfig.TEST_SAVE_DIR+"/t-test.xml");
					var e = d.create_element ("root");
					d.children.add (e);
					assert (d.children.size == 1);
					assert (d.root != null);
					assert (d.root.name == "root");
					assert (d.root.value == "");
					var root = (GXml.Element) d.root;
					var e1 = (GXml.Element) d.create_element ("child");
					e1.set_attr ("name","Test1");
					assert (e1.children.size == 0);
					root.children.add (e1);
					var e2 = (GXml.Element) d.create_element ("child");
					e2.set_attr ("name","Test2");
					assert (e2.children.size == 0);
					root.children.add (e2);
					assert (root.children.size == 2);
					d.save ();
					var istream = f.read ();
					uint8[] buffer = new uint8[2048];
					istream.read_all (buffer, null);
					istream.close ();
					assert ("<?xml version=\"1.0\"?>" in ((string)buffer));
					assert ("<root>" in ((string)buffer));
					assert ("</root>" in ((string)buffer));
					assert ("<child name=\"Test1\"/>" in ((string)buffer));
					assert ("<child name=\"Test2\"/>" in ((string)buffer));
				}
				catch (GLib.Error e) {
#if DEBUG
					GLib.message (@"ERROR: $(e.message)");
#endif
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/t-document/root/children-children", () => {
#if DEBUG
				GLib.message (@"TDocument root children/children...");
#endif
			try {
#if DEBUG
				GLib.message (@"Checking file to save to...");
#endif
				var f = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/t-large.xml");
				if (f.query_exists ()) f.delete ();
#if DEBUG
				GLib.message (@"Creating Document...");
#endif
				var d = new TDocument.for_path (GXmlTestConfig.TEST_SAVE_DIR+"/t-large.xml");
				var e = d.create_element ("bookstore");
				d.children.add (e);
				assert (d.children.size == 1);
				assert (d.root != null);
				assert (d.root.name == "bookstore");
				assert (d.root.value == "");
				var r = (GXml.Element) d.root;
				r.set_attr ("name","The Great Book");
#if DEBUG
				GLib.message (@"Creating chidls...");
#endif
				for (int i = 0; i < 5000; i++){
					var b = (GXml.Element) d.create_element ("book");
					r.children.add (b);
					var aths = (GXml.Element) d.create_element ("Authors");
					b.children.add (aths);
					var ath1 = (GXml.Element) d.create_element ("Author");
					aths.children.add (ath1);
					var name1 = (GXml.Element) d.create_element ("Name");
					name1.content = "Fred";
					ath1.children.add (name1);
					var email1 = (GXml.Element) d.create_element ("Email");
					email1.content = "fweasley@hogwarts.co.uk";
					ath1.children.add (email1);
					var ath2 = (GXml.Element) d.create_element ("Author");
					aths.children.add (ath2);
					var name2 = (GXml.Element) d.create_element ("Name");
					name2.content = "Greoge";
					ath2.children.add (name2);
					var email2 = (GXml.Element) d.create_element ("Email");
					email2.content = "gweasley@hogwarts.co.uk";
					ath2.children.add (email2);
				}
				assert (d.root.children.size == 5000);
				foreach (GXml.Node n in d.root.children) {
					assert (n.children.size == 1);
					foreach (GXml.Node cn in n.children) {
						assert (cn.children.size == 2);
						foreach (GXml.Node ccn in cn.children) {
							assert (ccn.children.size == 2);
						}
					}
				}
			}
			catch (GLib.Error e) {
				GLib.message (@"ERROR: $(e.message)");
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/t-document/save/children-children", () => {
#if DEBUG
				GLib.message (@"TDocument root children/children...");
#endif
			try {
#if DEBUG
				GLib.message (@"Checking file to save to...");
#endif
				var f = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/t-large.xml");
				if (f.query_exists ()) f.delete ();
#if DEBUG
				GLib.message (@"Creating Document...");
#endif
				var d = new TDocument.for_path (GXmlTestConfig.TEST_SAVE_DIR+"/t-large.xml");
				var e = d.create_element ("bookstore");
				d.children.add (e);
				assert (d.children.size == 1);
				assert (d.root != null);
				assert (d.root.name == "bookstore");
				assert (d.root.value == "");
				var r = (GXml.Element) d.root;
				r.set_attr ("name","The Great Book");
#if DEBUG
				GLib.message (@"Creating children...");
#endif
				for (int i = 0; i < 30000; i++){
					var b = (GXml.Element) d.create_element ("book");
					r.children.add (b);
					var aths = (GXml.Element) d.create_element ("Authors");
					b.children.add (aths);
					var ath1 = (GXml.Element) d.create_element ("Author");
					aths.children.add (ath1);
					var name1 = (GXml.Element) d.create_element ("Name");
					name1.content = "Fred";
					ath1.children.add (name1);
					var email1 = (GXml.Element) d.create_element ("Email");
					email1.content = "fweasley@hogwarts.co.uk";
					ath1.children.add (email1);
					var ath2 = (GXml.Element) d.create_element ("Author");
					aths.children.add (ath2);
					var name2 = (GXml.Element) d.create_element ("Name");
					name2.content = "Greoge";
					ath2.children.add (name2);
					var email2 = (GXml.Element) d.create_element ("Email");
					email2.content = "gweasley@hogwarts.co.uk";
					ath2.children.add (email2);
				}
				assert (d.root.children.size == 30000);
				d.save ();
				GLib.Test.message ("Reading saved file...");
				var fr = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/t-large.xml");
				assert (fr.query_exists ());
				var ostream = new MemoryOutputStream.resizable ();
				ostream.splice (fr.read (), GLib.OutputStreamSpliceFlags.NONE);
				assert ("<?xml version=\"1.0\"?>" in ((string)ostream.data));
				assert ("<bookstore name=\"The Great Book\">" in ((string)ostream.data));
				assert ("<book>" in ((string)ostream.data));
				assert ("<Authors>" in ((string)ostream.data));
				assert ("<Author>" in ((string)ostream.data));
				f.delete ();
			}
			catch (GLib.Error e) {
#if DEBUG
				GLib.message (@"ERROR: $(e.message)");
#endif
				assert_not_reached ();
			}
		});
		Test.add_func ("/gxml/t-document/save/backup", () => {
				try {
					var f = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/t-test.xml");
					if (f.query_exists ()) f.delete ();
					var ot = new TTestObject ();
					ot.name = "test1";
					var dt = new TDocument ();
					ot.serialize (dt);
					dt.save_as (f);
					var d = new TDocument ();
					var e = d.create_element ("root");
					d.children.add (e);
					assert (d.children.size == 1);
					assert (d.root != null);
					assert (d.root.name == "root");
					assert (d.root.value == "");
					d.save_as (f);
					assert (f.query_exists ());
					var bf = GLib.File.new_for_path (GXmlTestConfig.TEST_SAVE_DIR+"/t-test.xml~");
					assert (bf.query_exists ());
					var istream = f.read ();
					var b = new MemoryOutputStream.resizable ();
					b.splice (istream, 0);
					assert ("<?xml version=\"1.0\"?>" in ((string)b.data));
					assert ("<root/>" in ((string)b.data));
					f.delete ();
					bf.delete ();
				}
				catch (GLib.Error e) {
#if DEBUG
					GLib.message (@"ERROR: $(e.message)");
#endif
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/t-document/to_string", () => {
			var doc = new TDocument ();
			var r = doc.create_element ("root");
			doc.children.add (r);
#if DEBUG
			GLib.message (@"$(doc)");
#endif
			string str = doc.to_string ();
			assert ("<?xml version=\"1.0\"?>" in str);
			assert ("<root/>" in str);
			assert ("<root/>" in doc.to_string ());
		});
		Test.add_func ("/gxml/t-document/namespace", () => {
				try {
					var doc = new TDocument ();
					doc.children.add (doc.create_element ("root"));
					doc.set_namespace ("http://www.gnome.org/GXml","gxml");
					Test.message ("ROOT: "+doc.to_string ());
					assert (doc.root != null);
					assert (doc.namespaces != null);
					assert (doc.namespaces.size == 1);
					assert (doc.namespaces[0].prefix == "gxml");
					assert (doc.namespaces[0].uri == "http://www.gnome.org/GXml");
					doc.root.children.add (doc.create_element ("child"));
					assert (doc.root.children != null);
					assert (doc.root.children.size == 1);
					var c = doc.root.children[0];
					c.set_namespace ("http://www.gnome.org/GXml2","gxml2");
					assert (c.namespaces != null);
					assert (c.namespaces.size == 1);
					assert (c.namespaces[0].prefix == "gxml2");
					assert (c.namespaces[0].uri == "http://www.gnome.org/GXml2");
					(c as Element).set_attr ("gxml:prop","val");
					var p = (c as Element).get_attr ("gxml:prop");
					assert (p == null);
					Test.message ("ROOT: "+doc.to_string ());
					string[] str = doc.to_string ().split("\n");
					assert (str[1] == "<root xmlns:gxml=\"http://www.gnome.org/GXml\"><gxml2:child xmlns:gxml2=\"http://www.gnome.org/GXml2\"/></root>");
					(c as Element).set_ns_attr (doc.namespaces[0], "prop", "Ten");
					Test.message ("ROOT: "+doc.root.to_string ());
					assert (c.attrs.size == 1);
					var pt = c.attrs.get ("prop");
					assert (pt != null);
					var pt2 = (c as Element).get_ns_attr ("prop", doc.namespaces[0].uri);
					str = doc.to_string ().split("\n");
					assert (str[1] == "<root xmlns:gxml=\"http://www.gnome.org/GXml\"><gxml2:child xmlns:gxml2=\"http://www.gnome.org/GXml2\" gxml:prop=\"Ten\"/></root>");
				} catch (GLib.Error e) {
					GLib.message ("ERROR: "+ e.message);
					assert_not_reached ();
				}
			});
		Test.add_func ("/gxml/t-document/parent", () => {
			var doc = new TDocument ();
			assert (doc.parent == null);
		});
		Test.add_func ("/gxml/t-document/read/basic", () => {
			try {
				var f = GLib.File.new_for_path (GXmlTestConfig.TEST_DIR+"/t-read-test.xml");
				assert (f.query_exists ());
				var d = new TDocument ();
				TDocument.read_doc (d, f, null);
				GLib.message ("Doc:"+d.to_string ());
				assert (d.root != null);
				assert (d.root.name == "Sentences");
				assert (d.root.attrs["audience"] != null);
				assert (d.root.attrs["audience"].value == "All");
				assert (d.root.children.size == 4);
				var s1 = d.root.children[0];
				assert (s1 != null);
				assert (s1.name == "Sentence");
				var p1 = s1.attrs["lang"];
				assert (p1 != null);
				assert (p1.value == "en");
				assert (s1.children.size == 1);
				assert (s1.children[0] is GXml.Text);
				assert (s1.children[0].value == "I like the colour blue.");
				var s2 = d.root.children[1];
				assert (s2 != null);
				assert (s2.name == "Sentence");
				var p2 = s2.attrs["lang"];
				assert (p2 != null);
				assert (p2.value == "es");
				assert (s2.children.size == 1);
				assert (s2.children[0] is GXml.Text);
				assert (s2.children[0].value == "Español");
				var s3  = d.root.children[2];
				assert (s3 != null);
				assert (s3.name == "Authors");
				var p3 = s3.attrs["year"];
				assert (p3 != null);
				assert (p3.value == "2016");
				var p31 = s3.attrs["collection"];
				assert (p31 != null);
				assert (p31.value == "Back");
				assert (s3.children.size == 2);
				assert (s3.children[0] is GXml.Element);
				assert (s3.children[0].name == "Author");
				assert (s3.children[1].name == "Author");
				var a1 = s3.children[0];
				assert (a1 != null);
				assert (a1.name == "Author");
				assert (a1.children.size == 2);
				assert (a1.children[0].name == "Name");
				assert (a1.children[0].children.size == 1);
				assert (a1.children[0].children[0] is GXml.Text);
				assert (a1.children[0].children[0].value == "Fred");
				assert (a1.children[1].name == "Email");
				assert (a1.children[1].children.size == 1);
				assert (a1.children[1].children[0] is GXml.Text);
				assert (a1.children[1].children[0].value == "fweasley@hogwarts.co.uk");
				var a2 = s3.children[1];
				assert (a2 != null);
				assert (a2.children.size == 2);
				assert (a2.children[1].name == "Name");
				assert (a2.children[1].children.size == 1);
				assert (a2.children[1].children[0] is GXml.Text);
				assert (a2.children[1].children[0].value == "George");
				assert (a2.children[2].name == "Email");
				assert (a2.children[2].children.size == 1);
				assert (a2.children[2].children[0] is GXml.Text);
				assert (a2.children[2].children[0].value == "gweasley@hogwarts.co.uk");
			} catch (GLib.Error e) { GLib.message ("ERROR: "+e.message); assert_not_reached (); }
		});
		Test.add_func ("/gxml/t-document/read/namespace", () => {
			try {
				var f = GLib.File.new_for_path (GXmlTestConfig.TEST_DIR+"/t-read-test.xml");
				assert (f.query_exists ());
				var d = new TDocument ();
				TDocument.read_doc (d, f, null);
				GLib.message ("Doc:"+d.to_string ());
				assert (d.root != null);
				assert (d.root.name == "Sentences");
				assert (d.root.namespaces.size == 2);
				assert (d.root.namespaces[0].prefix == "gxml");
				assert (d.root.namespaces[0].uri == "http://wiki.gnome.org/GXml");
				assert (d.root.namespaces[1].prefix == "b");
				assert (d.root.namespaces[1].uri == "http://book.org/schema");
				var a = d.root.children[2];
				assert (a != null);
				assert (a.name == "Authors");
				assert (a.namespaces.size == 1);
				assert (a.namespaces[0].uri == "http://author.org");
				assert (a.namespaces[0].prefix == "auth");
				assert (a.children[0] != null);
				var a1 = a.children[0];
				assert (a1 != null);
				assert (a1.name == "Author");
				var e = a1.children[1];
				assert (e != null);
				assert (e.name == "Email");
				assert (e.namespaces.size == 1);
				assert (e.namespaces[0].prefix == "gxml");
				assert (e.namespaces[0].uri == "http://wiki.gnome.org/GXml");
				var b = d.root.children [3];
				assert (b != null);
				assert (b.name == "Book");
				assert (b.namespaces.size == 1);
				assert (b.namespaces[0].prefix == "b");
				assert (b.namespaces[0].uri == "http://book.org/schema");
				var bp = b.attrs["name"];
				assert (bp != null);
				assert (bp.name == "name");
				assert (bp.namespaces.size == 1);
				assert (bp.namespaces[0].prefix == "gxml");
				assert (bp.namespaces[0].uri == "http://wiki.gnome.org/GXml");
			} catch (GLib.Error e) { GLib.message ("ERROR: "+e.message); assert_not_reached (); }
		});
		Test.add_func ("/gxml/t-document/read/comment", () => {
			try {
				var f = GLib.File.new_for_path (GXmlTestConfig.TEST_DIR+"/t-read-test.xml");
				assert (f.query_exists ());
				var d = new TDocument ();
				TDocument.read_doc (d, f, null);
				assert (d.children[0] is GXml.Comment);
				assert (d.children[0].value == " Top Level Comment ");
				var a = d.root.children[2];
				assert (a.name == "Authors");
				var a1 = a.children[1];
				assert (a1.name == "Author");
				assert (a1.children[0] is GXml.Comment);
				assert (a1.children[0].value == " Inner comment");
				GLib.message ("Doc:"+d.to_string ());
			} catch (GLib.Error e) { GLib.message ("ERROR: "+e.message); assert_not_reached (); }
		});
		Test.add_func ("/gxml/t-document/read/PI", () => {
			try {
				var f = GLib.File.new_for_path (GXmlTestConfig.TEST_DIR+"/t-read-test.xml");
				assert (f.query_exists ());
				var d = new TDocument ();
				TDocument.read_doc (d, f, null);
				assert (d.children[1] is GXml.ProcessingInstruction);
				assert ((d.children[1] as GXml.ProcessingInstruction).target == "target");
				assert (d.children[1].value == "Content in target id=\"something\"");
				GLib.message ("Children:"+d.root.children.size.to_string ());
				foreach (GXml.Node n in d.root.children) {
					GLib.message ("Node name:"+n.name);
				}
				assert (d.root.children.size == 5);
				var p = (d.root.children[4]);
				assert (p != null);
				assert (p is GXml.ProcessingInstruction);
				assert ((p as GXml.ProcessingInstruction).target == "css");
				assert ((p as GXml.ProcessingInstruction).value == "href=\"http://www.gnome.org\"");
				GLib.message ("Doc:"+d.to_string ());
			} catch (GLib.Error e) { GLib.message ("ERROR: "+e.message); assert_not_reached (); }
		});
	}
}
