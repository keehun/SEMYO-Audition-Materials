extension StringProtocol {
    func properCase() -> String { prefix(1).uppercased() + dropFirst() }
}

extension String {
    static func +=(lhs: inout String, rhs: String) {
        lhs = lhs + rhs + "\n"
    }

    func bold() -> String {
        return #"\bold { "# + self + "}"
    }
}

extension Array where Element == Scale.Kind {
    func with(octaves: Int, tempo: Int) -> [Scale] {
        return self.map { Scale($0, oct: octaves, tempo: tempo) }
    }
}

// MARK: - Data Structures

struct Scale: CustomDebugStringConvertible {
    var debugDescription: String {
        return "\(name) (\(octave) Octaves)"
    }

    enum Kind: String {
        case C = "c d e f g a b"
        case c = "c d ees f g a b"
        case cs = "cis dis e fis gis a bis"
        case D = "d e fis g a b cis"
        case d = "d e f g a b cis"
        case E = "e fis gis a b cis dis"
        case e = "e fis g a b cis dis"
        case Eb = "ees f g aes bes c d"
        case F = "f g a bes c d e"
        case f = "f g aes bes c d e"
        case fs = "fis gis a b cis dis e"
        case G = "g a b c d e fis"
        case g = "g a bes c d e fis"
        case A = "a b cis d e fis gis"
        case a = "a b c d e fis gis"
        case Ab = "aes bes c des ees f g"
        case Bb = "bes c d ees f g a"
        case b = "b cis d e fis gis ais"

        func `for`(instrument: Instrument, octaves: Int) -> String {
            /// Here is where exceptions/clef overrides would go based on instrument and octaves.
            switch (instrument, octaves) {
            default:
                return Array(repeating: self.rawValue, count: octaves).joined(separator: " ") + " " + (self.rawValue.split(separator: " ").first ?? "")
            }
        }
    }

    func starting_oct(for instrument: Instrument) -> String {
        switch (self.kind, instrument) {
        case (.A, .flute), (.a, .flute), (.Ab, .flute), (.Bb, .flute), (.G, .flute), (.g, .flute):
            return "c''"
        default:
            return "c'"
        }
    }

    let tempo: Int
    let kind: Kind
    let octave: Int

    var octave_description: String {
        return "\(octave) Octave" + (octave > 1 ? "s" : "")
    }

    var name: String {
        switch kind {
        case .C : return "C Major"
        case .c : return "C Melodic Minor"
        case .cs: return "C-sharp Harmonic Minor"
        case .D : return "D Major"
        case .d : return "D Melodic Minor"
        case .E : return "E Major"
        case .e : return "E Melodic Minor"
        case .Eb: return "E-flat Major"
        case .F : return "F Major"
        case .f : return "F Melodic Minor"
        case .fs: return "F-sharp Melodic Minor"
        case .G : return "G Major"
        case .g : return "G Melodic Minor"
        case .A : return "A Major"
        case .a : return "A Melodic Minor"
        case .Ab: return "A-flat Major"
        case .Bb: return "B-flat Major"
        case .b : return "B Melodic Minor"
        }
    }

    var lilypond_code: String {
        switch kind {
        case .C : return #"c \major"#
        case .c : return #"c \minor"#
        case .cs: return #"cis \minor"#
        case .D : return #"d \major"#
        case .d : return #"d \minor"#
        case .E : return #"e \major"#
        case .e : return #"e \minor"#
        case .Eb: return #"ees \major"#
        case .F : return #"f \major"#
        case .f : return #"f \minor"#
        case .fs: return #"fis \minor"#
        case .G : return #"g \major"#
        case .g : return #"g \minor"#
        case .A : return #"a \major"#
        case .a : return #"a \minor"#
        case .Ab: return #"aes \major"#
        case .Bb: return #"bes \major"#
        case .b : return #"b \minor"#
        }
    }

    init(_ kind: Kind, oct: Int, tempo: Int) {
        self.kind = kind
        self.octave = oct
        self.tempo = tempo
    }
}

enum Clef {
    case treble
    case alto
    case bass
}

enum Instrument: String {
    case flute = "Flute"
    case oboe = "Oboe"
    case clarinet = "Clarinet"
    case bassoon = "Bassoon"
    case horn = "Horn"
    case trumpet = "Trumpet"
    case trombone = "Trombone"
    case tuba = "Tuba"
    case percussion = "Percussion"
    case harp = "Harp"
    case violin = "Violin"
    case viola = "Viola"
    case cello = "Cello"
    case bass = "Bass"
}

enum Orchestra: String {
    case cs = "Chamber Strings"
    case phil = "Philharmonic Orchestra"
    case concert = "Concert Orchestra"

    var long_description: String {
        switch self {
        case .cs:
            return "SEMYO’s beginning string ensemble is open to string players with a minimum of one or two years of playing experience. Orchestra members will be introduced to basic ensemble playing and will learn teamwork while playing a well-rounded selection of repertoire."
        case .phil:
            return "Philharmonic Orchestra is a full orchestra experience for students of all ages on string, woodwind, brass, and percussion instruments. String players typically need a minimum of 3-4 years of experience, and wind players typically need between 1 to 2 years of experience. Literature includes arranged and original works."
        case .concert:
            return "Concert Orchestra is a full orchestra experience for advanced students on string, woodwind, brass, and percussion instruments. Literature includes original masterworks for full symphony orchestra. Students will play music in all keys and utilize advanced bowing and string techniques."
        }
    }
}

struct Header {
    let text: String
    init(_ text: String) {
        self.text = text
    }
    var lilypond_code: String {
        return #"\markup { \vspace #1 } \markup { \fontsize #3 { ""# + text +  #""} } \markup { \vspace #1 }"#
    }
}

struct List {
    let items: [String]

    init(_ items: [String]) {
        self.items = items
    }

    var lilypond_code: String {
        return items.map { #"\markup { • \hspace #1 \wordwrap { "# + $0 + #"} \vspace #1 }"# }.joined(separator: "\n")
    }
}

struct Paragraph {
    let text: String
    init(_ text: String) {
        self.text = text
    }
    var lilypond_code: String {
        return #"\markup { \wordwrap { "# + text + " } }"
    }
}

struct Title {
    let text: String
    init(_ text: String) {
        self.text = text
    }
    var lilypond_code: String {
        return #"\header { subtitle = ""# + text + #""} \markup { \vspace #1 }"#
    }
}

struct Spacer {
    static var lilypond_code: String {
        return #"\markup { \vspace #1 }"#
    }
}

struct Page {
    let instrument: Instrument
    let clef: Clef
    let orchestra: Orchestra

    init(_ instrument: Instrument, clef: Clef, orchestra: Orchestra, scales: [Scale]) {
        self.instrument = instrument
        self.clef = clef
        self.orchestra = orchestra
        self._scales = scales
    }


    private var _scales: [Scale]
    var scales: [Scale] {
        get {
            var seen: Set<Scale.Kind> = []
            return _scales
                .sorted { sort_scales($0.kind, $0.octave, $1.kind, $1.octave) }
                .filter {
                    let hasBeenSeen = seen.contains($0.kind)
                    if !hasBeenSeen { seen.insert($0.kind) }
                    return !hasBeenSeen }
        }
        set {
            _scales = newValue
        }
    }

    private func sort_scales(_ kind1: Scale.Kind, _ oct1: Int, _ kind2: Scale.Kind, _ oct2: Int) -> Bool {
        if kind1 != kind2 {
            return kind1.rawValue < kind2.rawValue
        } else {
            return oct2 < oct1
        }
    }
}

// MARK: - Definitions

func audition_materials() -> [Page] {
    let four_sharps_and_flats: [Scale.Kind] = [.C, .G, .D, .E, .A, .F, .Bb, .Eb, .Ab,
                                               .a, .e, .b, .cs, .fs, .d, .g, .c, .f]
//    let four_sharps_and_flats_to_one_octave = four_sharps_and_flats.map { Scale($0, oct: 1) }
//    let four_sharps_and_flats_to_two_octave = four_sharps_and_flats.map { Scale($0, oct: 2) }

    let phil_octaves = 2
    let phil_scales: [Scale] = four_sharps_and_flats.map { Scale($0, oct: phil_octaves, tempo: 116) }

    let scales_for_beginner_violin = [Scale.Kind.G, .A, .Bb].with(octaves: 2, tempo: 80) + [Scale.Kind.F, .d, .C].with(octaves: 1, tempo: 80)
    let scales_for_cs_violin = Page(.violin, clef: .treble, orchestra: .cs,
                                    scales: scales_for_beginner_violin + [Scale.Kind.C, .D, .g].with(octaves: 2, tempo: 80))

    // MARK: - Pages


    let flute_phil = Page(.flute, clef: .treble, orchestra: .phil, scales: phil_scales)
    let clarinet_phil = Page(.clarinet, clef: .treble, orchestra: .phil, scales: phil_scales)
    let oboe_phil = Page(.oboe, clef: .treble, orchestra: .phil, scales: phil_scales)
    let bassoon_phil = Page(.bassoon, clef: .treble, orchestra: .phil, scales: phil_scales)
    let horn_phil = Page(.horn, clef: .treble, orchestra: .phil, scales: phil_scales)
    let trumpet_phil = Page(.trumpet, clef: .treble, orchestra: .phil, scales: phil_scales)
    let trombone_phil = Page(.trombone, clef: .treble, orchestra: .phil, scales: phil_scales)
    let tuba_phil = Page(.tuba, clef: .treble, orchestra: .phil, scales: phil_scales)
    let percussion_phil = Page(.percussion, clef: .treble, orchestra: .phil, scales: phil_scales)
    let violin_phil = Page(.violin, clef: .treble, orchestra: .phil, scales: phil_scales)
    let viola_phil = Page(.viola, clef: .alto, orchestra: .phil, scales: phil_scales)
    let cello_phil = Page(.cello, clef: .bass, orchestra: .phil, scales: phil_scales)
    let bass_phil = Page(.bass, clef: .bass, orchestra: .phil, scales: phil_scales)

    return [flute_phil/*, clarinet_phil, oboe_phil, bassoon_phil,
            horn_phil, trumpet_phil, trombone_phil, tuba_phil,
            percussion_phil,
            violin_phil, viola_phil, cello_phil, bass_phil*/]
}

func generate_lilypond_code(pages: [Page]) -> String {

    let prelude = #"""
    \paper {
      top-margin = 1\in
      left-margin = 1\in
      right-margin = 1\in
      bottom-margin = 1\in
      indent = 0\in
      print-page-number = ##f
      #(define fonts
        (set-global-fonts
         #:roman "Helvetica"
        ))
      tagline = ""
    }

    """#

    let score_suffix = #"""
    \layout {
        \context { \Staff \remove Time_signature_engraver }
        \context { \Staff \remove "Bar_engraver" }
    }
    """#


    var result = prelude

    for page in pages {
        result += #"\bookpart {"#
        result += Title("\(page.instrument.rawValue) / \(page.orchestra.rawValue)").lilypond_code
        result += Paragraph(page.orchestra.long_description).lilypond_code
        result += Header("1. Sightreading").lilypond_code
        result += Paragraph("You will be asked to sightread several excerpts. It will begin with easier excerpts and become more difficult. Those who wish to audition for concert orchestra should be familiar with famous orchestral excerpts for their instrument.").lilypond_code
        result += Header("2. Solo").lilypond_code
        result += List([
            "Prepare one solo that best demonstrates your abilities.",
            "Choose your selection with guidance from your private teacher or orchestra/band director.",
            "Solos need not be memorized.",
            "You will be asked to stop before you reach the end of the piece.",
            ]).lilypond_code
        result += Header("3. Scales").lilypond_code
        result += List([
            "Memorization of the scales is not required.",
            "At the audition students will choose the first scale and conductors will choose a second scale.",
            "See below for specific suggested (listed rhythms and tempos are general guidelines – please play scales in the range and tempo with which you are most comfortable).",
            ]).lilypond_code
        result += Spacer.lilypond_code
        result += Paragraph("Here are the scales you should prepare:".bold()).lilypond_code
        for scale in page.scales {
            result += Spacer.lilypond_code
            result += #"    \score {"#
            result += #"    \header { "# + "piece = \"\(scale.name), \(scale.octave_description)\" }"
            result += #"        \relative "# + "\(scale.starting_oct(for: page.instrument))" + " {"
            result += #"        \key "# + scale.lilypond_code
            result += #"            "# + scale.kind.for(instrument: page.instrument,
                                                        octaves: scale.octave)
            result += #"        }"#
            result += score_suffix
            result += #"    }"#
        }
        result += #"}"#
    }

    return result
}

print(generate_lilypond_code(pages: audition_materials()))
