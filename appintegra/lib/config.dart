/// Endereços usados pelo app, definidos em tempo de compilação com
/// `--dart-define`. Sem a opção, valem os padrões abaixo.
///
/// ```
/// flutter run --dart-define=API_URL=http://192.168.0.10:8000 \
///             --dart-define=HG_KEY=sua_chave_da_hg_brasil
/// ```
///
/// A chave da HG Brasil (`HG_KEY`) é lida em `pages/home_page.dart`.
class Config {
  Config._();

  /// API dos sensores e da bomba de irrigação (FastAPI publicada no Railway
  /// pela equipe). Rotas usadas: `GET /dados` e `POST /bomba` ({"estado": 0|1}).
  ///
  /// A instância do Railway está fora do ar; sem resposta, as telas de
  /// Sensores e Atuadores avisam e mostram dados de exemplo.
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://apimobile-production-8d8b.up.railway.app',
  );

  /// Fluxo do Langflow (Space no Hugging Face) que responde o chat.
  static const String langflowUrl = String.fromEnvironment(
    'LANGFLOW_URL',
    defaultValue:
        'https://gustavomp100-aula13langflow.hf.space/api/v1/run/28f6fd59-381b-40b4-94ac-0816132447d5',
  );

  /// Endpoint do clima da HG Brasil (https://console.hgbrasil.com).
  static const String hgWeatherUrl = 'https://api.hgbrasil.com/weather';
}
