package com.StudyInspector.webAPI.responses;

import com.fasterxml.jackson.annotation.JsonFormat;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
public class HttpResponseDto {
    @JsonFormat(shape = JsonFormat.Shape.STRING)
    private String message;
    @JsonFormat(shape = JsonFormat.Shape.OBJECT)
    private Object payload = null;

    public HttpResponseDto(String message) {
        this.message = message;
    }

    public HttpResponseDto(String message, Object payload) {
        this.message = message;
        this.payload = payload;
    }
}
