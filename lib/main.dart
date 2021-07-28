import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  // inicializa o firebase (obrigatório para qualquer recurso do firebase)
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // para pesquisar no banco de dados (firestore)
  FirebaseFirestore db = FirebaseFirestore.instance;
  var pesquisa = "gui";

  ///****************** Salvando e atualizando dados ******************/
  /// salva e/ou atualiza os dados no firebase
  /*db
      .collection("usuarios")
      .doc("005")
      .set({"nome": "Jamilton", "idade": "21"});*/

  /// salva criando uma chave aleatória no "document"
  /*DocumentReference ref = await db.collection("noticias").add(
      {"titulo": "Criada nova moeda", "descricao": "Foi criada..."});
  print("item salvo: " + ref.id);*/

  /// atualiza dados informando qual a chave do "document"
  /*db.collection("noticias").doc("UGtaPjM8mjktkUAuJ6RN").set(
      {"titulo": "Nova moeda é louca", "descricao": "Foi criada..."});*/

  ///****************** Removendo e recuperando dados ******************/
  /// remove dados passando o caminho
  //db.collection("usuarios").doc("003").delete();

  /// recupera os dados de um document (registro)
  /*DocumentSnapshot snapshot =
      await db.collection("usuarios").doc("001").get();
  // exibe em formato map
  print("dados: " + snapshot.data().toString());

  var dados = snapshot.data();
  // exibe os campos do map
  print("dados nome: ${(dados as dynamic)["nome"]} idade: ${(dados as dynamic)["idade"]}");*/

  /// recupera os dados de todos os document (registros) da collection (tabela)
  /*QuerySnapshot querySnapshot = await db.collection("usuarios").get();
  print("dados usuários: " + querySnapshot.docs.toString());

  // percorre o resultado completo
  for (DocumentSnapshot item in querySnapshot.docs) {
    var dados = item.data();
    print("dados nome: ${(dados as dynamic)["nome"]} idade: ${(dados as dynamic)["idade"]}");
  }*/

  /// adiciona o LISTEN, que executa (atualiza a tela) sempre que os dados forem alterados no banco de dados
  /*db.collection("usuarios").snapshots().listen((snapshot) {
    for (DocumentSnapshot item in snapshot.docs) {
      var dados = item.data();
      print("dados nome: ${(dados as dynamic)["nome"]} idade: ${(dados as dynamic)["idade"]}");
    }
  });*/

  /// filtros para pesquisa
  /*QuerySnapshot querySnapshot = await db
      .collection("usuarios")
      //.where("nome", isEqualTo: "guidim")
      //.where("idade", isEqualTo: "31")
      //.where("idade", isLessThan: 50)
      //.where("idade", isGreaterThan: 1)
      //.orderBy("idade", descending: false)
      //.orderBy("nome", descending: false)
      //.limit(2)

      // pesquisando textos
      .where("nome", isGreaterThanOrEqualTo: pesquisa)
      .where("nome", isLessThanOrEqualTo: pesquisa + "\uf8ff") //truque para pesquisar textos

      .get();

  for (DocumentSnapshot item in querySnapshot.docs) {
    var dados = item.data();
    print("filtro nome: ${(dados as dynamic)["nome"]} idade: ${dados["idade"]}");
  }*/

  ///****************** Autenticação de usuários ******************/
  // para fazer autenticações
  FirebaseAuth auth = FirebaseAuth.instance;

  String email = "guilhermereis2009@hotmail.com";
  String senha = "123456";

  /// criando um usuário com e-mail e senha
  /*await auth
      .createUserWithEmailAndPassword(email: email, password: senha)
      // faz isso caso a criação dê certo
      .then((firebaseUser) {
    print("Novo usuário: sucesso! e-mail: " + firebaseUser.user!.email!);
    // faz isso caso a criação dê errado
  }).catchError((erro) {
    print("Novo usuário: erro! " + erro.toString());
  });*/

  /// desloga o usuário que está logado no momento
  //await auth.signOut();

  /// loga um usuário já cadastrado
  /*await auth
      .signInWithEmailAndPassword(email: email, password: senha)
      .then((firebaseUser) {
    print("Login de usuário: sucesso! e-mail: " + firebaseUser.user!.email!);
  }).catchError((erro) {
    print("Login de usuário: erro! " + erro.toString());
  });*/

  /// recupera o usuário logado
  /*User? usuarioAtual = auth.currentUser;
  if (usuarioAtual != null) {
    // há um usuário logado
    print("Há um usuário logado com o email " + usuarioAtual.email!);
  } else {
    // não há usuário logado
    print("Não há usuário logado");
  }*/

  runApp(const MaterialApp(home: Home()));
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //PickedFile? _imagem;
  XFile? _imagem;
  String _statusUpload = "Upload não iniciado";
  String? _urlImagemRecuperada = null;

  ///************************** Upload de imagens ****************************/
  Future _recuperarImagem(bool daCamera) async {
    final imagemSelecionada;
    ImagePicker _picker = ImagePicker();

    if (daCamera) {
      imagemSelecionada = await _picker.pickImage(source: ImageSource.camera);
    } else {
      imagemSelecionada = await _picker.pickImage(source: ImageSource.gallery);
    }

    setState(() {
      _imagem = imagemSelecionada;
    });
  }

  Future _uploadImagem() async {
    // para acessar o armazenamento na nuvem
    FirebaseStorage storage = FirebaseStorage.instance;

    // referencia arquivo
    Reference pastaRaiz = storage.ref();
    Reference arquivo = pastaRaiz.child("fotos").child("foto1.jpg");

    // faz upload da imagem
    UploadTask task = arquivo.putFile(File(_imagem!.path));

    // controla progresso do upload
    task.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
      if (taskSnapshot.state == TaskState.running) {
        setState(() {
          _statusUpload = "Em progresso...";
        });
      } else if (taskSnapshot.state == TaskState.success) {
        _recuperarUrlImagem(taskSnapshot);
        setState(() {
          _statusUpload = "Upload realizado com sucesso!";
        });
      }
    });
  }

  Future _recuperarUrlImagem(TaskSnapshot taskSnapshot) async {
    String url = await taskSnapshot.ref.getDownloadURL();
    print("resultado url: " + url);
    setState(() {
      _urlImagemRecuperada = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Selecionar imagem"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 20, top: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      _recuperarImagem(true);
                    },
                    child: const Text("Da Câmera"),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: ElevatedButton(
                    onPressed: () {
                      _recuperarImagem(false);
                    },
                    child: const Text("Da Galeria"),
                  ),
                ),
              ],
            ),
            _imagem == null
                ? Container()
                : Padding(
                    padding: const EdgeInsets.fromLTRB(130, 10, 130, 10),
                    child: Image.file(File(_imagem!.path)),
                  ),
            _imagem == null
                ? Container()
                : ElevatedButton(
                    onPressed: () {
                      _uploadImagem();
                    },
                    child: const Text("Upload Storage"),
                  ),
            _imagem == null ? Container() : Text(_statusUpload),
            _urlImagemRecuperada == null
                ? Container()
                : Padding(
                    padding: const EdgeInsets.fromLTRB(130, 10, 130, 10),
                    child: Image.network(_urlImagemRecuperada!),
                  ),
          ],
        ),
      ),
    );
  }
}
