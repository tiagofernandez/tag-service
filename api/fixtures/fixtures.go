package fixtures

import (
	"encoding/json"
	"io/ioutil"
	"log"

	"github.com/buger/jsonparser"
)

var fixturePaths = map[string]string{
	"feature-flags": "./fixtures/feature-flags.json",
}

func loadFeatureFlags() map[string]interface{} {
	data := loadFile(fixturePaths["feature-flags"])
	flags := make(map[string]interface{})

	if data != nil {
		jsonparser.ArrayEach(data, func(value []byte, dataType jsonparser.ValueType, offset int, e error) {
			id, err := jsonparser.GetString(value, "id")

			if err != nil {
				log.Fatal("Error getting id", value, err)
			} else {
				var valueAsJson map[string]interface{}
				err = json.Unmarshal(value, &valueAsJson)

				if err != nil {
					log.Fatal("Error decoding value", value, err)
				}
				flags[id] = valueAsJson
			}
		}, "results")
	}
	return flags
}

func loadFile(path string) []byte {
	data, err := ioutil.ReadFile(path)
	if err != nil {
		log.Fatal("Error reading file", path, err)
	}
	return data
}
