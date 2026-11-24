import '../models/reader.dart';
import '../repositories/ai_repository.dart';
import '../repositories/repository_exception.dart';
import '../repositories/wallet_repository.dart';
import 'fake_config.dart';
import 'samples/reader_samples.dart';

/// Canned [AiRepository]: no model call. Each answer costs [talonCost]
/// talons, taken through the wallet before the answer is returned.
///
/// Text about the input-process-output cycle (frame 87/91's sentence) gets a
/// tailored answer; any other text gets a generic one.
final class FakeAiRepository implements AiRepository {
  FakeAiRepository(this._config, {required this._wallet});

  /// "Uses 1 talon credit" (91).
  static const talonCost = 1;

  final FakeConfig _config;
  final WalletRepository _wallet;

  @override
  Future<Explanation> explain({
    required String materialId,
    required String text,
    ExplainAction action = ExplainAction.explain,
    ExplainLanguage language = ExplainLanguage.english,
  }) async {
    // Scenario and latency first, so a failing call never costs talons.
    await _config.answer<void>('explain', () {});
    if (action == ExplainAction.highlight) {
      throw const RepositoryException('Highlight is not an AI action');
    }
    final label = sampleMaterialLabels[materialId];
    if (label == null) {
      throw RepositoryException('Unknown material "$materialId"');
    }
    await _wallet.spendTalons(talonCost, reason: 'AI ${action.label}');
    final topical = _isAboutCycle(text);
    return Explanation(
      text: (topical ? _topical : _generic)[action]![language]!,
      language: language,
      // ignore: avoid_redundant_argument_values
      talonCost: talonCost,
      sourceLabel: 'Based on your $label Reviewer',
    );
  }

  static bool _isAboutCycle(String text) {
    final t = text.toLowerCase();
    return t.contains('input') || t.contains('computer');
  }

  static const _topical = <ExplainAction, Map<ExplainLanguage, String>>{
    ExplainAction.explain: {
      ExplainLanguage.english:
          'A computer is an electronic machine that receives input, '
          'processes information using instructions, and gives you a useful '
          'result as output. It can also store that information for later.',
      ExplainLanguage.tagalog:
          'Ang computer ay isang elektronikong makina na tumatanggap ng '
          'input, nagpoproseso ng impormasyon gamit ang mga tagubilin, at '
          'nagbibigay ng kapaki-pakinabang na resulta bilang output.',
      ExplainLanguage.taglish:
          'Ang computer ay isang electronic machine na tumatanggap ng '
          'input, nagpo-process ng information gamit ang instructions, at '
          'nagbibigay ng useful na result bilang output.',
    },
    ExplainAction.example: {
      ExplainLanguage.english:
          'Example: when you type on a keyboard, that is the input. The '
          'computer processes it and shows the letters on the screen as '
          'output.',
      ExplainLanguage.tagalog:
          'Halimbawa: kapag nagta-type ka sa keyboard, iyon ang input. '
          'Pinoproseso ito ng computer at ipinapakita ang resulta sa screen '
          'bilang output.',
      ExplainLanguage.taglish:
          "Halimbawa: kapag nagta-type ka sa keyboard, 'yan ang input. "
          'Piniproseso ito ng computer at ipinapakita ang result sa screen '
          'bilang output.',
    },
    ExplainAction.quizMe: {
      ExplainLanguage.english:
          'Quick check: in the input-process-output cycle, which step '
          'happens when the computer follows instructions to work on your '
          'data? (A) Input (B) Process (C) Output. Answer: Process.',
      ExplainLanguage.tagalog:
          'Mabilis na tanong: sa input-process-output cycle, aling hakbang '
          'ang nangyayari kapag sinusunod ng computer ang mga tagubilin '
          'para gawin ang iyong data? (A) Input (B) Process (C) Output. '
          'Sagot: Process.',
      ExplainLanguage.taglish:
          'Quick check: sa input-process-output cycle, anong step ang '
          'nangyayari kapag sinusunod ng computer ang instructions para '
          'i-work ang data mo? (A) Input (B) Process (C) Output. Sagot: '
          'Process.',
    },
  };

  static const _generic = <ExplainAction, Map<ExplainLanguage, String>>{
    ExplainAction.explain: {
      ExplainLanguage.english:
          'This part of your reviewer states one main idea. Read the '
          'sentence again, find the key term, and try to say it in your own '
          'words.',
      ExplainLanguage.tagalog:
          'Ang bahaging ito ng iyong reviewer ay may isang pangunahing '
          'ideya. Basahin muli ang pangungusap, hanapin ang mahalagang '
          'termino, at subukang sabihin ito sa sarili mong salita.',
      ExplainLanguage.taglish:
          'Ang part na ito ng reviewer mo ay may isang main idea. Basahin '
          'ulit ang sentence, hanapin ang key term, at subukang sabihin ito '
          'sa sarili mong words.',
    },
    ExplainAction.example: {
      ExplainLanguage.english:
          'Example: think of something you use every day that matches this '
          'idea, then describe how it works step by step.',
      ExplainLanguage.tagalog:
          'Halimbawa: mag-isip ng bagay na ginagamit mo araw-araw na '
          'tumutugma sa ideyang ito, at ilarawan kung paano ito gumagana '
          'nang paunti-unti.',
      ExplainLanguage.taglish:
          'Halimbawa: mag-isip ng bagay na ginagamit mo everyday na '
          'tumutugma sa idea na ito, then i-describe kung paano ito gumagana '
          'step by step.',
    },
    ExplainAction.quizMe: {
      ExplainLanguage.english:
          'Quick check: in your own words, what is the main idea of this '
          'sentence, and why does it matter?',
      ExplainLanguage.tagalog:
          'Mabilis na tanong: sa sarili mong salita, ano ang pangunahing '
          'ideya ng pangungusap na ito, at bakit ito mahalaga?',
      ExplainLanguage.taglish:
          'Quick check: sa sarili mong words, ano ang main idea ng sentence '
          'na ito, at bakit ito important?',
    },
  };
}
