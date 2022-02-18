package com.vmware.scg.extensions.filter;

import java.util.Collections;
import java.util.List;
import java.util.Map;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.springframework.cloud.gateway.filter.GatewayFilter;
import org.springframework.cloud.gateway.filter.factory.AbstractGatewayFilterFactory;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ServerWebExchange;

import static com.vmware.scg.extensions.filter.FeatureFlagsGatewayFilterFactory.FF_ATTRIBUTE;

@Component
public class DumpFeatureFlagsGatewayFilterFactory extends AbstractGatewayFilterFactory<Object> {

	private static final Logger LOGGER = LoggerFactory.getLogger(DumpFeatureFlagsGatewayFilterFactory.class);

	static final String FF_HEADER = "X-Feature-Flags";

	@Override
	public GatewayFilter apply(Object config) {
		return (exchange, chain) -> {
			Map<String, Object> featureFlags = exchange.getAttributeOrDefault(FF_ATTRIBUTE, Collections.emptyMap());

			try {
				String json = new ObjectMapper().writeValueAsString(featureFlags);

				ServerWebExchange updatedExchange = exchange.mutate()
						.request(request -> {
							request.headers(headers -> {
								headers.put(FF_HEADER, List.of(json));
								LOGGER.info("Processed request, added" + FF_HEADER + " header");
							});
						})
						.build();

				return chain.filter(updatedExchange);
			}
			catch (JsonProcessingException e) {
				LOGGER.error("Failed to serialize feature flags", e);
			}
			return chain.filter(exchange);
		};
	}
}
