package com.vmware.scg.extensions.filter;

import java.util.Map;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.springframework.cloud.gateway.filter.GatewayFilter;
import org.springframework.cloud.gateway.filter.factory.AbstractGatewayFilterFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.reactive.function.client.WebClient;

@Component
public class FeatureFlagsGatewayFilterFactory extends AbstractGatewayFilterFactory<Object> {

	public static final String FF_ATTRIBUTE = "feature-flags";

	private static final Logger LOGGER = LoggerFactory.getLogger(FeatureFlagsGatewayFilterFactory.class);

	@Override
	public GatewayFilter apply(Object config) {
		return ((exchange, chain) -> {
			return WebClient.create()
					.get()
					.uri("https://gist.githubusercontent.com/tiagofernandez/cf6edfb98412e4f8fcba2069bfee05ee/raw/09fd8b5f010d23d2854de9eaefc24d35b83a9b66/feature-flags.json")
					.retrieve()
					.bodyToMono(String.class)
					.flatMap(json -> {
						try {
							Map<String, Object> featureFlags = new ObjectMapper()
									.readValue(json, new TypeReference<Map<String,Object>>(){});

							exchange.getAttributes().put(FF_ATTRIBUTE, featureFlags);
							return chain.filter(exchange);
						}
						catch (JsonProcessingException e) {
							LOGGER.error("Failed to deserialize feature flags", e);
						}
						return chain.filter(exchange);
					});
			});
	}

}
