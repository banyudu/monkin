import Foundation

struct MotionProgram: Codable, Equatable {
    var seed: UInt64
    var duration: Double
    var layers: [MotionLayer]

    init(seed: UInt64 = 0, duration: Double = 4.0, layers: [MotionLayer]) {
        self.seed = seed
        self.duration = duration
        self.layers = layers
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        seed = try container.decodeIfPresent(UInt64.self, forKey: .seed) ?? 0
        duration = try container.decodeIfPresent(Double.self, forKey: .duration) ?? 4.0
        layers = try container.decode([MotionLayer].self, forKey: .layers)
    }
}

struct MotionLayer: Codable, Equatable {
    var channel: String
    var waveform: String
    var amplitude: Double
    var speed: Double
    var phase: Double
    var offset: Double
    var pulseStart: Double?
    var pulseEnd: Double?

    init(channel: String, waveform: String, amplitude: Double,
         speed: Double = 0, phase: Double = 0, offset: Double = 0,
         pulseStart: Double? = nil, pulseEnd: Double? = nil) {
        self.channel = channel
        self.waveform = waveform
        self.amplitude = amplitude
        self.speed = speed
        self.phase = phase
        self.offset = offset
        self.pulseStart = pulseStart
        self.pulseEnd = pulseEnd
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        channel = try container.decode(String.self, forKey: .channel)
        waveform = try container.decode(String.self, forKey: .waveform)
        amplitude = try container.decode(Double.self, forKey: .amplitude)
        speed = try container.decodeIfPresent(Double.self, forKey: .speed) ?? 0
        phase = try container.decodeIfPresent(Double.self, forKey: .phase) ?? 0
        offset = try container.decodeIfPresent(Double.self, forKey: .offset) ?? 0
        pulseStart = try container.decodeIfPresent(Double.self, forKey: .pulseStart)
        pulseEnd = try container.decodeIfPresent(Double.self, forKey: .pulseEnd)
    }
}
