enum MessageScreen {
  title("Bem Vindo (a)"),
  subtitle("Sistema de gerenciamento de vendas fiadas"),
  buttonLoginName("Entrar"),
  buttonRegisterName("Registra-se"),
  forgotPassword("Esqueceu sua senha ?"),
  noEmptyField("Todos os campos devem ser preenchidos !"),
  enter("Entrar"),
  continueLogin("Continuar"),
  emailLabel("Email"),
  passwordLabel("Senha"),
  continueWithGoogle("Continue com o Google"),
  or("OU");

  final String value;

  const MessageScreen(this.value);
}

enum ImagePathEnum {
  logoImagePath("assets/images/logo_with_name.png"),
  iconGoogle("assets/icons/devicon_google.svg");

  final String value;

  const ImagePathEnum(this.value);
}
