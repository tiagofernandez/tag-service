package com.vmware.scg.extensions.filter;

import com.github.tomakehurst.wiremock.WireMockServer;
import com.github.tomakehurst.wiremock.matching.MatchesJsonPathPattern;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestInstance;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.test.autoconfigure.web.reactive.AutoConfigureWebTestClient;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.web.reactive.server.WebTestClient;

import static com.github.tomakehurst.wiremock.client.WireMock.get;
import static com.github.tomakehurst.wiremock.client.WireMock.getRequestedFor;
import static com.github.tomakehurst.wiremock.client.WireMock.ok;
import static com.github.tomakehurst.wiremock.client.WireMock.urlPathEqualTo;
import static com.vmware.scg.extensions.filter.DumpFeatureFlagsGatewayFilterFactory.FF_HEADER;

@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@AutoConfigureWebTestClient
@TestInstance(TestInstance.Lifecycle.PER_CLASS)
class DumpFeatureFlagsTest {

	final WireMockServer wireMock = new WireMockServer(7414);

	final String route = "/api/fixtures/feature-flags";

	@Autowired
	WebTestClient webTestClient;

	@BeforeAll
	void setUp() {
		wireMock.stubFor(get(route).willReturn(ok()));
		wireMock.start();
	}

	@AfterAll
	void tearDown() {
		wireMock.stop();
	}

	@Test
	void shouldDumpContextInHeader() {
		webTestClient
				.get()
				.uri(route)
				.exchange()
				.expectStatus()
				.isOk();

		wireMock.verify(getRequestedFor(urlPathEqualTo(route))
				.withHeader(FF_HEADER, new MatchesJsonPathPattern("$.1st-feature-flag")));
	}

	@SpringBootApplication
	public static class GatewayApplication {

		public static void main(String[] args) {
			SpringApplication.run(GatewayApplication.class, args);
		}
	}
}
