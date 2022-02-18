package fixtures

import (
	"testing"
)

func init() {
	fixturePaths["feature-flags"] = "../../fixtures/feature-flags.json"
}

func TestLoadFeatureFlags(t *testing.T) {
	flags := loadFeatureFlags()

	for _, key := range []string{"1st-feature-flag", "2nd-feature-flag", "3rd-feature-flag"} {
		if flags[key] == nil {
			t.Error("Not all flags were loaded")
		}
	}
}

func BenchmarkLoadFeatureFlags(b *testing.B) {
	for i := 0; i < b.N; i++ {
		loadFeatureFlags()
	}
}
