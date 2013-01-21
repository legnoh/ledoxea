﻿package {	import flash.display.BitmapData;	import flash.display.Sprite;	import flash.display.SimpleButton;	import flash.events.*;	import flash.filesystem.StorageVolumeInfo;	import flash.geom.Matrix;	import flash.geom.Vector3D;	import flash.text.*;	import flash.utils.ByteArray;	import flash.utils.escapeMultiByte;	import flash.net.URLLoader;	import flash.net.URLRequest;	import flash.ui.Keyboard;	import flash.desktop.NativeApplication;	import away3d.containers.*;	import away3d.entities.*;	import away3d.materials.TextureMaterial;	import away3d.primitives.*;	import away3d.textures.BitmapTexture;	import br.com.stimuli.loading.BulkLoader;	import br.com.stimuli.loading.BulkProgressEvent;	import com.hurlant.crypto.hash.HMAC;	import com.hurlant.crypto.hash.SHA256;	import com.hurlant.util.Base64;	/*---------------------------------------------------------------------	Away3DによるWWW可視化、Androidによる縦横方向への操作可能	@author Ryoma Kai	---------------------------------------------------------------------*/	public class Main extends View3D {				private var view:View3D;		private var text_field:TextField;		private var title_field:TextField;		private var disc_field:TextField;		private var format:TextFormat;		private var titleFmt:TextFormat;		private var discFmt:TextFormat;		private var up:State;		private var over:State;		private var starPoints:Array;		private var keyword:String;		private var normXML:XML;		private var imgXML:XML;		private var docXML:XML;		private var mvXML:XML;		private var amaXML:XML;		private var normNS:Namespace;		private var imgNS:Namespace;		private var docNS:Namespace;		private var mvNS:Namespace;		private var amaNS:Namespace;		private var media:Namespace;		private var imgs:BulkLoader;		private var num:int;		private var col:String;		private var startZ:int;		public function Main():void {			/****ここから検索ボックス、検索結果の文章表示部まわりの描画****/			text_field = new TextField();			title_field = new TextField();			disc_field = new TextField();			format = new TextFormat();			titleFmt = new TextFormat();			discFmt = new TextFormat();			up = new State(0x0,stage.stageWidth*0.2);			over = new State(0xFF4500,stage.stageWidth*0.2);			starPoints = new Array();			keyword = new String();			num = new int();			num = 0;			startZ = new int();			startZ = -200;			col = new String;			col = "norm";						normXML = new XML();			imgXML = new XML();			docXML = new XML();			mvXML = new XML();			amaXML = new XML();			imgs =new BulkLoader();						normNS = new Namespace("urn:yahoo:jp:srch");			imgNS = new Namespace("urn:yahoo:jp:srchmi");			docNS = new Namespace("urn:yahoo:jp:srch");			mvNS = mvXML.namespace("");			media = mvXML.namespace("media");			amaNS = new Namespace("http://webservices.amazon.com/AWSECommerceService/2011-08-01");									//検索ボックス、ボタン、結果表示部の２行をステージに乗せて、フォーマット・スタイル定義			setSearchBox();			stage.addChild(title_field);			setTitleFormat(titleFmt,"");			title_field.defaultTextFormat = titleFmt;			setTitleStyle(title_field);			stage.addChild(disc_field);			setDiscriptionFormat(discFmt,"");			disc_field.defaultTextFormat = discFmt;			setDiscriptionStyle(disc_field);			makeButton();						/****ここからAway3D系の描画処理****/			backgroundColor=0xFFFFFF;// 背景を白色に			camera.lens.far=10000;// 遠くも見えるように設定						// 線を作成			var lines:SegmentSet = new SegmentSet();			scene.addChild(lines);						addEventListener(Event.ENTER_FRAME, enterFrameHandler);			addEventListener(TransformGestureEvent.GESTURE_SWIPE, moveCamera);		}		/**view3D空間のレンダリングを行う*/		private function enterFrameHandler(e:Event):void {			camera.x = 0;			camera.z = 2000;			camera.y = 0;			camera.lookAt(new Vector3D(0, 0, 0));			render();		}				/**検索ボタン押下直後の初期位置までのレンダリング(カメラの初期位置移動)*/		private function enterSearch(e:Event){			camera.x = 0;			camera.y = 1600;			camera.z = -200;			camera.lookAt(new Vector3D(0,0,-200));			camera.rotationY = 0;			render();						removeEventListener(Event.ENTER_FRAME, enterSearch);			addEventListener(Event.ENTER_FRAME, enterMoveCamera);		}				private function enterMoveCamera(e:Event){			render();		}				/**検索結果表示後、スワイプに合わせてカメラの移動*/		private function moveCamera(e:TransformGestureEvent):void{			var cameraRot:Array = new Array(); // カメラの回転角を保持する行列						//どの方向にスワイプしたかを判定			if (e.offsetY == -1) {								//下から上へスワイプした場合、19個目の検索結果でない場合、下の項目へ移動				if (num!=19){										//下の要素へ参照を移動					num++;										//カメラ位置の変更・1フレーム毎のレンダリング処理					for (var i:int=0; i<10; i++) {						cameraRot = [camera.rotationX,camera.rotationY,camera.rotationZ];						camera.z-=20;						startZ-=20;						camera.lookAt(new Vector3D(0,0,startZ));						camera.rotationX = cameraRot[0];						camera.rotationY = cameraRot[1];						camera.rotationZ = cameraRot[2];						render();					}				}			} else if (e.offsetY == 1) {								//上から下にスワイプした場合、numが0でないならば、上の項目へ移動				if (num!=0) {										//上の要素へ参照を移動					num--;										//カメラ位置の変更・1フレーム毎のレンダリング処理					for (var j:int=0; i<10; i++) {						cameraRot = [camera.rotationX,camera.rotationY,camera.rotationZ];						camera.z += 20;						startZ += 20;						camera.lookAt(new Vector3D(0,0,startZ));						camera.rotationX = cameraRot[0];						camera.rotationY = cameraRot[1];						camera.rotationZ = cameraRot[2];						render();					}				}							} else if(e.offsetX==1){								//左から右へスワイプした場合、左列の要素に参照を移す				if(col=="norm"){										//Yahoo!検索結果の列ならYoutube検索結果の列へ遷移					col="mv";					camera.x = -1521;					camera.y = 494;					camera.lookAt(new Vector3D(0,0,camera.z));					camera.rotationX = 90;					camera.rotationY = 0;					camera.rotationZ = 72;								}else if(col=="img"){										//画像検索結果の列ならYahoo!検索結果の列へ遷移					col="norm";					camera.x = 0;					camera.y = 1600;					camera.lookAt(new Vector3D(0,0,camera.z));					camera.rotationX = 90;					camera.rotationY = 0;					camera.rotationZ = 0;								}else if(col=="doc"){										//ドキュメント検索結果の列なら画像検索結果の列へ遷移					col="img";					camera.x = 1521;					camera.y = 494;					camera.lookAt(new Vector3D(0,0,camera.z));					camera.rotationX = 90;					camera.rotationY = 0;					camera.rotationZ = -72;									}else if(col=="ama"){										//Amazon検索結果の列ならドキュメント検索結果の列へ遷移					col="doc";					camera.x = 940;					camera.y = -1294;					camera.lookAt(new Vector3D(0,0,camera.z));					camera.rotationX = -90;					camera.rotationY = 180;					camera.rotationZ = 36;								}else if(col=="mv"){										//Youtube検索結果の列ならAmazonの検索結果の列へ遷移					col="ama";					camera.x = -940;					camera.y = -1294;					camera.lookAt(new Vector3D(0,0,camera.z));					camera.rotationX = -90;					camera.rotationY = 180;					camera.rotationZ = -36;				}							} else if(e.offsetX==-1){								///右から左へスワイプした場合、右列の要素に参照を移す				if(col=="mv"){										//Youtubeの検索結果の列ならYahoo!検索結果の列へ遷移					col="norm";					camera.x = 0;					camera.y = 1600;					camera.lookAt(new Vector3D(0,0,camera.z));					camera.rotationX = 90;					camera.rotationY = 0;					camera.rotationZ = 0;								}else if(col=="norm"){										//Yahoo!検索結果の列なら画像検索結果の列へ遷移					col="img";					//Imgへの遷移(確定)					camera.x = 1521;					camera.y = 494;					camera.lookAt(new Vector3D(0,0,camera.z));					camera.rotationX = 90;					camera.rotationY = 0;					camera.rotationZ = -72;								}else if(col=="img"){										//画像検索結果の列ならドキュメント検索結果の列へ遷移					col="doc";					camera.x = 940;					camera.y = -1294;					camera.lookAt(new Vector3D(0,0,camera.z));					camera.rotationX = -90;					camera.rotationY = 180;					camera.rotationZ = 36;								}else if(col=="doc"){										//ドキュメント検索結果の列ならAmazonの検索結果の列へ遷移					col="ama";					camera.x = -940;					camera.y = -1294;					camera.lookAt(new Vector3D(0,0,camera.z));					camera.rotationX = -90;					camera.rotationY = 180;					camera.rotationZ = -36;								}else if(col=="ama"){										//AmazonならYoutubeの検索結果列へ遷移					col="mv";					camera.x = -1521;					camera.y = 494;					camera.lookAt(new Vector3D(0,0,camera.z));					camera.rotationX = 90;					camera.rotationY = 0;					camera.rotationZ = 72;				}			}						//タイトル・Disc部分変更・フォーマット上書き			rewriteSummary();		}		/**検索ボックスのフォーマットを定義する*/		public function setSearchBox() {			stage.addChild(text_field);			format.align = TextFormatAlign.LEFT;// 整列			format.font  = "MotoyaLMaru";			format.size  = 85;// 文字のポイントサイズ			format.color = 0x0E0E0E;// 文字の色			format.kerning = true;// カーニングが有効か？（埋め込みフォント時のみ動作）			text_field.defaultTextFormat = format;			text_field.x=18;// x 座標			text_field.y=18;// y 座標			text_field.width = stage.stageWidth * 0.7;// 幅			text_field.height=100;// 高さ			text_field.type=TextFieldType.INPUT;// テキストフィールドのタイプ			text_field.antiAliasType=AntiAliasType.ADVANCED;// アンチエイリアスの種類			text_field.autoSize=TextFieldAutoSize.NONE;// サイズ整形の種類			text_field.background=false;			text_field.border=true;// 境界線があるか？			text_field.borderColor=0x0F0F0F;// 境界線の色			text_field.condenseWhite=false;// HTML表示時にスペース改行などを削除するか？			text_field.gridFitType=GridFitType.NONE;// グリッドフィッティングの種類			text_field.multiline=false;// 複数行か？			text_field.selectable=true;// 選択可能か？			text_field.sharpness=0;// 文字エッジのシャープネス			text_field.thickness=1;// 文字エッジの太さ			text_field.useRichTextClipboard=false;// コピペ時に書式もコピーするか？			text_field.wordWrap=false;// 折り返すか？			text_field.text="java";		}				/**検索結果のタイトル表示スタイルを定義する*/		public function setTitleStyle(txt:TextField) {			txt.x=5;// x 座標			txt.y=772;// y 座標			txt.width = stage.stageWidth * 0.7;// 幅			txt.height=100;// 高さ			txt.type=TextFieldType.DYNAMIC;// テキストフィールドのタイプ			txt.antiAliasType=AntiAliasType.ADVANCED;// アンチエイリアスの種類			txt.autoSize=TextFieldAutoSize.NONE;// サイズ整形の種類			txt.condenseWhite=false;// HTML表示時にスペース改行などを削除するか？			txt.gridFitType=GridFitType.NONE;// グリッドフィッティングの種類			txt.multiline=false;// 複数行か？			txt.selectable=true;// 選択可能か？			txt.sharpness=0;// 文字エッジのシャープネス			txt.thickness=1;// 文字エッジの太さ			txt.useRichTextClipboard=false;// コピペ時に書式もコピーするか？			txt.wordWrap=false;// 折り返すか？			txt.text="Title";		}				/**検索結果のタイトル表示フォーマットを定義する*/		public function setTitleFormat(fmt:TextFormat,uri:String) {			fmt.align = TextFormatAlign.LEFT;// 整列			fmt.font  = "MotoyaLMaru";			fmt.bold  = true;			fmt.underline = true; // アンダーラインを表示するか？			fmt.size  = 40;// 文字のポイントサイズ			fmt.color = 0xFF0000;// 文字の色			fmt.kerning = true;// カーニングが有効か？（埋め込みフォント時のみ動作）			fmt.url = uri; // ハイパーリンク先を文字列で指定			fmt.target = null; // ハイパーリンク先のターゲットウィンドウ		}				/**検索結果のディスクリプション表示スタイルを定義する*/		public function setDiscriptionStyle(txt:TextField) {			txt.x=5;// x 座標			txt.y=814;// y 座標			txt.width = stage.stageWidth;			txt.height=100;			txt.type = TextFieldType.DYNAMIC;			txt.antiAliasType=AntiAliasType.ADVANCED; // アンチエイリアスの種類			txt.alwaysShowSelection = true; // フォーカスが無くなっても選択状態を維持するか？ 			txt.condenseWhite = false; // HTML表示時にスペース改行などを削除するか？			txt.multiline = false; // 複数行か？			txt.selectable = true; // 選択可能か？			txt.textColor = 0x000000; // テキストの色			txt.autoSize = TextFieldAutoSize.LEFT;			txt.useRichTextClipboard = false; // コピペ時に書式もコピーするか？			txt.wordWrap = false; // 折り返すか？			txt.text="Discription";		}				/**検索結果のディスクリプション表示フォーマットを定義する*/		public function setDiscriptionFormat(fmt:TextFormat,uri:String) {			fmt.align = TextFormatAlign.LEFT; // 整列			fmt.font  = "MotoyaLMaru";			fmt.size = 35; // 文字サイズ			fmt.color = 0x000000; // 文字の色			fmt.underline = true; // アンダーラインを表示するか？			fmt.kerning = true; // カーニング有効			fmt.url = uri; // ハイパーリンク先を文字列で指定			fmt.target = null; // ハイパーリンク先のターゲットウィンドウ		}				/**検索ボタンを作る*/		public function makeButton(){			var btn:SimpleButton = new SimpleButton();						btn.upState = up;			btn.downState = over;			btn.overState = up;			btn.hitTestState = up;			btn.x = 360;			btn.y = 18;			btn.addEventListener(MouseEvent.CLICK,onButtonPush);			stage.addChild(btn);		}				/**星の5点の座標を計算する*/		public function makeStar(rad:int,grad:Number){						var starPoint:Array = []; //xy座標を交互に入れた配列						//1つ目の座標			starPoint.push(rad * Math.cos(grad));			starPoint.push(rad * Math.sin(grad));						//2つ目の座標			starPoint.push(rad * Math.cos(0.4*Math.PI + grad));			starPoint.push(rad * Math.sin(0.4*Math.PI + grad));						//3つ目の座標			starPoint.push(rad * Math.cos(0.8*Math.PI + grad));			starPoint.push(rad * Math.sin(0.8*Math.PI + grad));						//4つ目の座標			starPoint.push(rad * Math.cos(1.2*Math.PI + grad));			starPoint.push(rad * Math.sin(1.2*Math.PI + grad));						//5つ目の座標			starPoint.push(rad * Math.cos(1.6*Math.PI + grad));			starPoint.push(rad * Math.sin(1.6*Math.PI + grad));						return starPoint;		}				/**5件の検索をネットワーク越しにぶん投げて結果をXMLで受け取る*/		private function onButtonPush(e:MouseEvent):void {						//星を描く５点の座標を計算する			starPoints = makeStar(400,0.5*Math.PI);						//星のエッジを描く			drawEdge(starPoints[0],starPoints[1],0);			drawEdge(starPoints[2],starPoints[3],0);			drawEdge(starPoints[4],starPoints[5],0);			drawEdge(starPoints[6],starPoints[7],0);			drawEdge(starPoints[8],starPoints[9],0);						//加えてノードを描く			drawNode(0,0,0,starPoints[0],starPoints[1],0);			drawNode(0,0,0,starPoints[2],starPoints[3],0);			drawNode(0,0,0,starPoints[4],starPoints[5],0);			drawNode(0,0,0,starPoints[6],starPoints[7],0);			drawNode(0,0,0,starPoints[8],starPoints[9],0);						//５つの検索用リクエストURLにアクセスし、結果を描画する			normSearch(1);			imgSearch(1);			docSecrch(1);			mvSearch(1);			amaSearch(1);						//カメラの位置をYahoo!検索で持ってきた値のトップに据える			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);			addEventListener(Event.ENTER_FRAME, enterSearch);		}				/**Yahoo!検索(通常の検索)を行う*/		public function normSearch(page:int){						//リクエストURL			var url = "http://search.yahooapis.jp/PremiumWebSearchService/V1/webSearch?"			+"appid=LFTNFXWxg66eYMmIvFGGF1qZLo8V8HMPgqMou_HBPPhe4p5LSNCf.lkFBRjKNtE-&"			+"results=20&"			+"query=" + text_field.text + " 基礎 OR 講座";						var loader:URLLoader = new URLLoader();			var request:URLRequest=new URLRequest(url);			loader.addEventListener(Event.COMPLETE,function(event:Event) {													//XMLから名前空間を削除				normXML = new XML(event.target.data).removeNamespace("http://www.w3.org/2001/XMLSchema-instance");								//タイトル部分を検索１番目のものに変更・フォーマット上書き				title_field.text = normXML.normNS::Result[0].normNS::Title;				setTitleFormat(titleFmt,normXML.normNS::Result[0].normNS::Url);								//Summary部分も同様に変更・フォーマット上書き				disc_field.text = normXML.normNS::Result[0].normNS::Summary;				setDiscriptionFormat(discFmt,normXML.normNS::Result[0].normNS::Url);								//テキストフォーマットに設定し直す				title_field.setTextFormat(titleFmt);				disc_field.setTextFormat (discFmt);												//検索結果に対応するノードを20個描画する				for(var i=0; i<20;i++){					drawEdge(starPoints[0],starPoints[1],(-2000*(page-1))+(-200*i));				}			});			loader.load(request);		}				/**Yahoo!画像検索を行う*/		public function imgSearch(page:int){						//リクエストURL			var url = "http://search.yahooapis.jp/PremiumImageSearchService/V1/imageSearch?"			+ "appid=LFTNFXWxg66eYMmIvFGGF1qZLo8V8HMPgqMou_HBPPhe4p5LSNCf.lkFBRjKNtE-&"			+ "results=20&"			+ "query=" + text_field.text + " 基礎 OR 講座";						var loader:URLLoader = new URLLoader();			var request:URLRequest=new URLRequest(url);						loader.addEventListener(Event.COMPLETE,function(event:Event) {													//XMLから名前空間を削除				imgXML = new XML(event.target.data).removeNamespace("http://www.w3.org/2001/XMLSchema-instance");								//サムネで画像を20個描画する				var thumbLoader = new BulkLoader();				thumbLoader.add("star.png");								for(var i:int=0; i<20;i++){					thumbLoader.add(imgXML.imgNS::Result[i].imgNS::Url.toString());					if(imgXML.imgNS::Result[i+1]==null){break;}				}								thumbLoader.addEventListener(BulkProgressEvent.COMPLETE, function(event:BulkProgressEvent):void{										// 画像を表示					for(var i:int=0; i<20;i++){						var img = imgXML.imgNS::Result[i].imgNS::Url.toString(); 						var regPattern:RegExp = /.+(bmp|png|jpg|jpeg)$/i; //.bmp .png .jpg .jpegの拡張子を持つファイル名の正規表現												// イメージがきちんと拡張子をもっている場合、1024x1024まで引き伸ばしてリサイズ						if(regPattern.test(img)){							var bmd:BitmapData = thumbLoader.getBitmapData(imgXML.imgNS::Result[i].imgNS::Url.toString());							bmd = resize(bmd,1024/imgXML.imgNS::Result[i].imgNS::Width.toString(),1024/imgXML.imgNS::Result[i].imgNS::Height.toString());						}else{							bmd = thumbLoader.getBitmapData("star.png");						}						if(bmd.height!=bmd.width){							if(bmd.height > bmd.width){bmd = resize(bmd, bmd.height/bmd.width , 1 ); }							else{bmd = resize(bmd, 1 , bmd.width/bmd.height ); }							bmd = resize(bmd,1024/bmd.width,1024/bmd.height);						}						if(bmd.height>256){							bmd = resize(bmd,1024/bmd.width,1024/bmd.height);						}						var texture:BitmapTexture = new BitmapTexture(bmd);						var material:TextureMaterial = new TextureMaterial(texture);						material.alphaBlending=true;												//ビルボード処理						var sprite3D:Sprite3D=new Sprite3D(material,170,170);						if(img==""){ sprite3D = new Sprite3D(material,200,200); }						scene.addChild(sprite3D);						sprite3D.x = starPoints[8];						sprite3D.y = starPoints[9];						sprite3D.z = (-2000*(page-1))+(-200*i)-200;												if(imgXML.imgNS::Result[i+1]==null){break;}					}				});				thumbLoader.start();			});			loader.load(request);		}				/**Yahoo!検索(PDFのみ検索)を行う*/		public function docSecrch(page:int){						//リクエストURL			var url = "http://search.yahooapis.jp/PremiumWebSearchService/V1/webSearch?"			+ "appid=LFTNFXWxg66eYMmIvFGGF1qZLo8V8HMPgqMou_HBPPhe4p5LSNCf.lkFBRjKNtE-&"			+ "results=20&"			+ "format=pdf&"			+ "query=" + text_field.text + " 基礎 OR 講座";						var loader:URLLoader = new URLLoader();			var request:URLRequest=new URLRequest(url);						loader.addEventListener(Event.COMPLETE,function(event:Event) {								[Embed(source="pdf.png")]				var ImageClpdf:Class; // PDFの画像													//XMLから名前空間を削除				docXML = new XML(event.target.data).removeNamespace("http://www.w3.org/2001/XMLSchema-instance");									var bmd:BitmapData = new ImageClpdf().bitmapData;				var texture:BitmapTexture=new BitmapTexture(bmd);				var material:TextureMaterial=new TextureMaterial(texture);				material.alphaBlending=true;								//ビルボード処理をしつつ、20個のノードを描画する				for(var i:int=0;i<20;i++){					var sprite3D:Sprite3D=new Sprite3D(material,170,170);					scene.addChild(sprite3D);					sprite3D.x = starPoints[6];					sprite3D.y = starPoints[7];					sprite3D.z = (-2000*(page-1))+(-200*i)-200;				}			});			loader.load(request);		}				/**Youtube検索を行う*/		public function mvSearch(page:int){						//リクエストURL			var url = "http://gdata.youtube.com/feeds/api/videos?"			+ "max-results=20&"			+ "q=" + text_field.text + " 基礎 OR 講座";						var loader:URLLoader = new URLLoader();			var request:URLRequest=new URLRequest(url);						loader.addEventListener(Event.COMPLETE,function(event:Event) {													//XMLから必要のない5つの名前空間を削除				mvXML = new XML(event.target.data).removeNamespace("http://a9.com/-/spec/opensearchrss/1.0/").removeNamespace("http://schemas.google.com/g/2005").removeNamespace("http://gdata.youtube.com/schemas/2007").removeNamespace("http://www.opengis.net/gml").removeNamespace("http://www.georss.org/georss");								media = mvXML.namespace("media");				mvNS = mvXML.namespace("");								var thumbLoader = new BulkLoader();								// サムネイルのURLをBulkLoaderに追加				for(var i:int=0; i<20;i++){					thumbLoader.add(mvXML.mvNS::entry[i].media::group.media::thumbnail[2].@url.toString());					if(mvXML.mvNS::entry[i+1]==null){break;}				}								thumbLoader.addEventListener(BulkProgressEvent.COMPLETE, function(event:BulkProgressEvent):void{										//画像を表示					for(var i:int=0; i<20;i++){						var img = mvXML.mvNS::entry[i].media::group.media::thumbnail[2].@url.toString(); //サムネイル画像のURL						var bmd:BitmapData = thumbLoader.getBitmapData(img);												//256x256にリサイズ						bmd = resize(bmd,256/mvXML.mvNS::entry[i].media::group.media::thumbnail[2].@width,									 	 256/mvXML.mvNS::entry[i].media::group.media::thumbnail[2].@height);									 						//アルファチャンネルを含むサムネイルが画像サイズをオーバーしている時のために、						//正方形になっていないファイルは更に画像サイズ確認の後リサイズし、256x256でリサイズ						if(bmd.height!=bmd.width){							if(bmd.height > bmd.width){bmd = resize(bmd, bmd.height/bmd.width , 1 ); }							else{bmd = resize(bmd, 1 , bmd.width/bmd.height ); }							bmd = resize(bmd,256/bmd.width,256/bmd.height);						}												//256x256を越えた場合、512x512で再度リサイズ						if(bmd.height>256){							bmd = resize(bmd,512/bmd.width,512/bmd.height);						}												var texture:BitmapTexture = new BitmapTexture(bmd);						var material:TextureMaterial = new TextureMaterial(texture);						material.alphaBlending=true;												//ビルボード処理をしつつ、20個のノードをサムネイル画像で描画						var sprite3D:Sprite3D=new Sprite3D(material,160,120);						if(img==""){ sprite3D = new Sprite3D(material,200,200); }						scene.addChild(sprite3D);						sprite3D.x = starPoints[2];						sprite3D.y = starPoints[3];						sprite3D.z = (-2000*(page-1))+(-200*i)-200;												if(mvXML.mvNS::entry[i+1]==null){break;}					}														});				thumbLoader.start();			});			loader.load(request);		}				/**Amazon商品検索を行う*/		public function amaSearch(page:int){						var loader:URLLoader = new URLLoader();			var requestUri:String = "ecs.amazonaws.jp";			var requestPath:String = "/onca/xml";			var amazonSecretKey:String = "JwjNUQm36RDnv2T7yW8QUaVYN1CeHmogsD/rjhpe";			var timestamp:String = makeTimeStamp();						var query:String = "AWSAccessKeyId=AKIAJEEDDCG5F452QBHA&"			+ "AssociateTag=lyok-22&"			+ "Keywords="+ escapeMultiByte(text_field.text)+"&"			+ "Operation=ItemSearch&"			+ "ResponseGroup=Medium&"			+ "SearchIndex=Books&"			+ "Service=AWSECommerceService&"			+ "Timestamp=" + escape(timestamp) + "&"			+ "Version=2011-08-01";						// 署名の生成			var signatureText:String = ["GET", requestUri, requestPath, query].join("\n"); // 署名する文書			var signature:String = makeSignature(signatureText, amazonSecretKey);						// URLエンコードした署名をクエリの最後に追加して、リクエストURLを完成させる			query += "&Signature=" + escapeMultiByte(signature);			var url:String = "http://" + requestUri + requestPath + "?" + query;						// amazonへアクセス			loader.addEventListener(Event.COMPLETE,function(event:Event) {													//XMLから名前空間を削除				amaXML = new XML(event.target.data);								var thumbLoader = new BulkLoader();				thumbLoader.add("star.png");								for(var i:int=0; i<20;i++){					var img = amaXML.amaNS::Items.amaNS::Item[i].amaNS::MediumImage.amaNS::URL.toString();					if(img!=""){thumbLoader.add(img);}					if(amaXML.amaNS::Items.amaNS::Item[i+1]==null){break;}				}								thumbLoader.addEventListener(BulkProgressEvent.COMPLETE, function(event:BulkProgressEvent):void{											 					var bmd = thumbLoader.getBitmapData("star.png");										// 商品画像がある場合は、256x256でリサイズする					// 無い場合は星画像を代理で使用する					for(var i:int=0; i<20;i++){						var img = amaXML.amaNS::Items.amaNS::Item[i].amaNS::MediumImage.amaNS::URL.toString();												if(img!=""){							bmd = thumbLoader.getBitmapData(img);							bmd = resize(bmd,256/amaXML.amaNS::Items.amaNS::Item[i].amaNS::MediumImage.amaNS::Width.toString(),										 	 256/amaXML.amaNS::Items.amaNS::Item[i].amaNS::MediumImage.amaNS::Height.toString());						}else{							bmd = thumbLoader.getBitmapData("star.png");						}												var texture:BitmapTexture = new BitmapTexture(bmd);						var material:TextureMaterial = new TextureMaterial(texture);						material.alphaBlending=true;												// ビルボード処理しつつ、商品画像のノードを描画する						// 商品画像がある場合はそのサイズで、ない場合は星画像の大きさで調整する						var sprite3D:Sprite3D= new Sprite3D(material,amaXML.amaNS::Items.amaNS::Item[i].amaNS::MediumImage.amaNS::Width.toString(),																	 amaXML.amaNS::Items.amaNS::Item[i].amaNS::MediumImage.amaNS::Height.toString());						if(img==""){ sprite3D = new Sprite3D(material,200,200); }						scene.addChild(sprite3D);						sprite3D.x = starPoints[4];						sprite3D.y = starPoints[5];						sprite3D.z = (-2000*(page-1))+(-200*i)-200;												if(amaXML.amaNS::Items.amaNS::Item[i+1]==null){break;}					}				});				thumbLoader.start();			});						loader.load(new URLRequest(url));		}				/**colの要素とnumの列で指定されたSummaryに書き換える*/		public function rewriteSummary(){						//colの値がnormならば、numの値で指定された値をSummaryに置き換える			if(col=="norm"){				title_field.text = normXML.normNS::Result[num].normNS::Title;				setTitleFormat(titleFmt,normXML.normNS::Result[num].normNS::Url);				disc_field.text = normXML.normNS::Result[num].normNS::Summary;				setDiscriptionFormat(discFmt,normXML.normNS::Result[num].normNS::Url);			}						//colの値がimgならば、numの値で指定された値をSummaryに置き換える			if(col=="img"){				title_field.text = imgXML.imgNS::Result[num].imgNS::Title;				setTitleFormat(titleFmt,imgXML.imgNS::Result[num].imgNS::Url);				disc_field.text = imgXML.imgNS::Result[num].imgNS::Summary;				setDiscriptionFormat(discFmt,imgXML.imgNS::Result[num].imgNS::Url);			}						//colの値がdocならば、numの値で指定された値をSummaryに置き換える			else if(col=="doc"){				title_field.text = docXML.docNS::Result[num].docNS::Title;				setTitleFormat(titleFmt,docXML.docNS::Result[num].docNS::Url);				disc_field.text = docXML.docNS::Result[num].docNS::Summary;				setDiscriptionFormat(discFmt,docXML.docNS::Result[num].docNS::Url);			}						//colの値がmvならば、numの値で指定された値をSummaryに置き換える			else if(col=="mv"){				title_field.text = mvXML.mvNS::entry[num].mvNS::title;				var testin = mvXML.mvNS::entry[num].mvNS::link.(@rel=="alternate").@href.toString();				setTitleFormat(titleFmt,mvXML.mvNS::entry[num].mvNS::link.(@rel=="alternate").@href.toString());				disc_field.text = mvXML.mvNS::entry[num].mvNS::content;				setDiscriptionFormat(discFmt,mvXML.mvNS::entry[num].mvNS::link.(@rel=="alternate").@href.toString());			}						//colの値がamaならば、numの値で指定された値をSummaryに置き換える			else if(col=="ama"){				title_field.text = amaXML.amaNS::Items.amaNS::Item[num].amaNS::ItemAttributes.amaNS::Title.toString();				setTitleFormat(titleFmt,amaXML.amaNS::Items.amaNS::Item[num].amaNS::DetailPageURL);				disc_field.text = amaXML.amaNS::Items.amaNS::Item[num].amaNS::ItemAttributes.amaNS::Author.toString();				setDiscriptionFormat(discFmt,amaXML.amaNS::Items.amaNS::Item[num].amaNS::DetailPageURL);			}			title_field.setTextFormat(titleFmt);			disc_field.setTextFormat (discFmt);		}		/**指定した２つのScene3D地点間にノードを描画する*/		public function drawNode(x:int,y:int,z:int,x2:int,y2:int,z2:int) {						//引数で貰った2点間にラインを引く			var lines:SegmentSet = new SegmentSet();			scene.addChild(lines);			lines.addSegment(new LineSegment(new Vector3D(x,y,z),new Vector3D(x2,y2,z2),0xEEEEEE,0xEEEEEE,4));		}		/**指定したScene3D地点上にエッジを描画する*/		public function drawEdge(x:int,y:int,z:int) {						[Embed(source="star.png")]			var ImageCls:Class; // 星の画像								//画像を表示			var bmd:BitmapData = new ImageCls().bitmapData;			var texture:BitmapTexture=new BitmapTexture(bmd);			var material:TextureMaterial=new TextureMaterial(texture);			material.alphaBlending=true;							//ビルボード処理			var sprite3D:Sprite3D=new Sprite3D(material,200,200);			scene.addChild(sprite3D);			sprite3D.x = x;			sprite3D.y = y;			sprite3D.z = z;		}				/**署名する文書と、ハッシュキーを引数として受取り、String型のHMAC-SHA256署名データを返す*/		private function makeSignature(signatureText:String, key:String):String{						//HMAC-SHA256署名を行うクラス			var hmac256:HMAC = new HMAC(new SHA256());						// 署名する文書のバイトデータ			var signatureTextBytes:ByteArray = new ByteArray();			signatureTextBytes.writeUTFBytes(signatureText);						// 署名用のハッシュキーのバイトデータ			var keyBytes:ByteArray = new ByteArray();			keyBytes.writeUTFBytes(key);						// HMAC-SHA256署名を行い、ダイジェストを生成			var digest256:ByteArray = hmac256.compute(keyBytes, signatureTextBytes);						// ダイジェストをBase64でString型にエンコード			var signature:String = Base64.encodeByteArray(digest256);						return signature;		}				/**AmazonAPI用タイムスタンプを生成する*/		private function makeTimeStamp():String{			var timeStamper:Date = new Date(); //現時刻			var timestamp:String = timeStamper.getUTCFullYear() + "-"			+ to2size(timeStamper.getUTCMonth() + 1) + "-"			+ to2size(timeStamper.getUTCDate()) + "T"			+ to2size(timeStamper.getUTCHours()) + ":"			+ to2size(timeStamper.getUTCMinutes()) + ":"			+ to2size(timeStamper.getUTCSeconds());			return timestamp;		}				/**日付や時分秒が10未満の場合、2桁となるよう左に0を挿入する*/		private function to2size( data:Number ):String{			var strData:String = data.toString();			if (data < 10) { strData = "0" + strData; }			return strData;		}				/**Bitmapデータをリサイズする*/		public function resize(src:BitmapData, hRatio:Number, vRatio:Number):BitmapData{						var res:BitmapData = new BitmapData( Math.ceil(src.width * hRatio), Math.ceil(src.height * vRatio) );			res.draw(src, new Matrix(hRatio, 0, 0, vRatio), null, null, null, true);			return res;		}	}}import flash.display.Sprite;import flash.text.TextField;import flash.text.TextFormat;/**ボタンの色を与えてボタンのデザインを形作るStateクラス*/class State extends Sprite{		public function State(color:int,btnWeight:int){			graphics.lineStyle(1.0, color);	graphics.beginFill(0xFFFFFF);	graphics.drawRect(0, 0, btnWeight, 100);	graphics.endFill();	 	var tf:TextField = new TextField();	tf.defaultTextFormat = new TextFormat("_typeWriter", 20, color, true);	tf.text = "検索";	tf.autoSize = "left";	tf.x = (this.width  - tf.width)  / 2;	tf.y = (this.height - tf.height) / 2;	tf.selectable = false;	addChild(tf);	}}