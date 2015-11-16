package com.guigarage.sdk.animations;

import javafx.animation.FadeTransition;
import javafx.animation.Interpolator;
import javafx.animation.ParallelTransition;
import javafx.animation.TranslateTransition;
import javafx.scene.layout.Region;
import javafx.util.Duration;

public class FadeInBottomTransition {

    public static ParallelTransition create(Duration duration, Region node) {
        TranslateTransition translateTransition = new TranslateTransition(duration, node);
        translateTransition.setInterpolator(Interpolator.EASE_IN);
        translateTransition.setFromY(node.getTranslateY());
        translateTransition.setToY(0);

        FadeTransition fadeTransition = new FadeTransition(duration, node);
        fadeTransition.setFromValue(node.getOpacity());
        fadeTransition.setToValue(1.0);

        return new ParallelTransition(translateTransition, fadeTransition);
    }
}
