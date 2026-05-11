enum MessageScreen {
  title("Bem Vindo (a)"),
  subtitle("Sistema de gerenciamento de vendas fiadas"),
  buttonLoginName("Entrar"),
  buttonRegisterName("Registra-se"),
  forgotPassword("Esqueceu sua senha ?"),
  noEmptyField("Todos os campos devem ser preenchidos !"),
  enter("Entrar"),
  sendLabel("Enviar"),
  continueLogin("Continuar"),
  emailLabel("Email"),
  passwordLabel("Senha"),
  continueWithGoogle("Continue com o Google"),
  or("OU"),
  nameLabel("Nome"),
  confirmPasswordLabel("Confirme sua Senha"),
  messagePassRequired(
    "Use 8+ caracteres distribuidos entre letras, números e especiais",
  ),
  msgForgPassPageTitle("Me passa seu e-mail ?"),
  msgForgPassPageSubTitle("Vamos te enviar um link de recuperação");

  final String value;

  const MessageScreen(this.value);
}

enum ImagePathEnum {
  logoImagePath("assets/images/logo_with_name.png"),
  iconGoogle("assets/icons/devicon_google.svg");

  final String value;

  const ImagePathEnum(this.value);
}

enum RoutesPathEnum {
  forgotPassword("/forgotPassword");

  final String value;

  const RoutesPathEnum(this.value);
}
