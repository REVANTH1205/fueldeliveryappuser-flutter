import 'package:firebase_auth/firebase_auth.dart';
import 'package:gmaptest/modal/user_modal.dart';


final FirebaseAuth fAuth = FirebaseAuth.instance;
User? currentFirebaseUser;
UserModal? userModalcurrentinfo;
List dList = [] ;//contains driver key info
String? chosenDriverId="";
String cloudMessagingServerToken = "key=AAAASovSGlc:APA91bEy2jf6dULSimH1sQT6_-qApCqIT4TkR8iHt11RNGIGGRA0Gx-nhSjhb0YURHl9zcilsxYyojqWqMr6K1UokQelp_hjSy2040fBL26uj9j2yfKsMN3ZaEmSe5K0DiHl5BnNLccj";