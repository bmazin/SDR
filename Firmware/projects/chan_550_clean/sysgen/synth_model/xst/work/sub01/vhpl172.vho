     9 H �        P0N         ��         G   IEEE       IEEE ��     �  &)   IEEE   std_logic_1164   all     ��     �  &*   IEEE   numeric_std   all     ��     :   conv_pkg  Y ��        E  #)  2�  >�  J9  U�  a�  ma  y  ��  ��  �Y  �  ��  ��  �9  ��  �I 	� ! <i S� kI �� �� �i �� �I >9 t� �� �	 � � G� v� �� �y Y I� �� �I �� ) Ky �� �	 �� �) i A� h� �Q �� � � $! GI f� �� �9 �� ۹ �� i 9y P� p) �� �	       G  '  6�  Bi  N!  Y�  e�  qI  }  ��  �q  �)  ��  ��  �Q  �	  ��  � q (� D9 [� s �Y �� �9 ة � F	 |� �� �� ��  � O� ~� �i �I ) Qy �� � �� � SI �� �� � � &9 Ia pq �! �a �q � +� O nY �� �	 �y � � 9 AI X� w� �i ��  �  �          Y     X  �  q     ��     v  ��          '     :   
simulating  '  q     !  &,  #)     A  �R  q     v �          6�     @     6�     :   
xlUnsigned  6�  q     !  &1  2�     *�  .�  q     @     Bi     :   xlSigned  Bi  q     !  &2  >�     *�  :�  q     @     N!     :   xlWrap  N!  q     !  &3  J9     *�  FQ  q     @     Y�     :   
xlSaturate  Y�  q     !  &4  U�     *�  R	  q     @     e�     :   
xlTruncate  e�  q     !  &5  a�     *�  ]�  q     @     qI     :   xlRound  qI  q     !  &6  ma     *�  iy  q     @     }     :   xlRoundBanker  }  q     !  &7  y     *�  u1  q     @     ��     :   	xlAddMode  ��  q     !  &8  ��     *�  ��  q     @     �q     :   	xlSubMode  �q  q     !  &9  ��     *�  ��  q     :   	black_box  �)  q     v  ��          �)       &:  �Y  �A  q     :   syn_black_box  ��  q     v  ��          ��       &;  �  ��  q     :   fpga_dont_touch  ��  q     v ��          ��       &<  ��  ��  q     :   box_type  �Q  q     v ��          �Q       &=  ��  �i  q     :   keep  �	  q     v ��          �	       &>  �9  �!  q     :   syn_keep  ��  q     v  ��          ��       &?  ��  ��  q          �y         �a          �     v  �[          �a     :   inp  �a  ީ     !  &@  �y      �      ީ     :   std_logic_vector_to_unsigned  �  q     v  J<          �     5  &@  �I         �[  J<  ީ  �1  q         �        �         q     v  J<         �     :   inp �  �     !  &A �      ��      �     :   unsigned_to_std_logic_vector q  q     v  �[         q     5  &A 	�         J<  �[  � �  q         A        )         (�     :   inp ) Y     !  &B A      �     Y     :   std_logic_vector_to_signed (�  q     v  Y�         (�     5  &B !         �[  Y� Y $�  q         4�        8�         D9     v  Y�         8�     :   inp 8� ,�     !  &C 4�     0�     ,�     :   signed_to_std_logic_vector D9  q     v  �[         D9     5  &C <i         Y�  �[ ,� @Q  q         L	        O�         [�     :   inp O� H!     !  &D L	      ��     H!     :   unsigned_to_signed [�  q     v  Y�         [�     5  &D S�         J<  Y� H! W�  q         cy        ga         s     :   inp ga _�     !  &E cy     0�     _�     :   signed_to_unsigned s  q     v  J<         s     5  &E kI         Y�  J< _� o1  q         z� ��        ~� ��         �Y     :   inp ~� w     !  &F z�      �     w     :   arith �� w     !  &F ��      *�     w     :   pos �Y  q     v  ��         �Y     5  &F ��         �[ �  �� w �q  q         �)        �         ��     :   inp � �A     !  &G �)      �     �A     :   all_same ��  q     v  ��         ��     5  &G ��         �[  �� �A ��  q         ��        ��         �9     :   inp �� ��     !  &H ��      �     ��     :   	all_zeros �9  q     v  ��         �9     5  &H �i         �[  �� �� �Q  q         �	        ��         ة     :   inp �� �!     !  &I �	      �     �!     :   is_point_five ة  q     v  ��         ة     5  &I ��         �[  �� �! ��  q         �y        �a         �     :   inp �a ܑ     !  &J �y      �     ܑ     :   all_ones �  q     v  ��         �     5  &J �I         �[  �� ܑ �1  q        	 �� �� � Y ) � &� .� 6i       	 �� � q A  "� *� 2� :Q         F	     :   inp �� �     !  &K ��      �     �     :   	old_width � �     !  &K ��      *�     �     :   
old_bin_pt q �     !  &K �      *�     �     :   	old_arith A �     !  &L Y      *�     �     :   	new_width  �     !  &L )      *�     �     :   
new_bin_pt "� �     !  &L �      *�     �     :   	new_arith *� �     !  &L &�      *�     �     :   quantization 2� �     !  &M .�      *�     �     :   overflow :Q �     !  &M 6i      *�     �     :   convert_type F	  q     v  �[         F	     5  &K >9       
  �[ � � � � � � � �  �[ � B!  q         M� U� ]y eI m        Q� Y� aa i1 q         |�     :   inp Q� I�     !  &O M�      �     I�     :   
old_bin_pt Y� I�     !  &O U�      *�     I�     :   	new_width aa I�     !  &P ]y      *�     I�     :   
new_bin_pt i1 I�     !  &P eI      *�     I�     :   	new_arith q I�     !  &P m      *�     I�     :   cast |�  q     v  �[         |�     5  &O t�         �[ � � � �  �[ I� x�  q         �� �Y �)        �q �A �         ��     :   inp �q ��     !  &R ��      �     ��     :   upper �A ��     !  &R �Y      *�     ��     :   lower � ��     !  &R �)      *�     ��     :   	vec_slice ��  q     v  �[         ��     5  &R ��         �[ � �  �[ �� ��  q         �� �i �9        �� �Q �!         ��     :   inp �� ��     !  &T ��     0�     ��     :   upper �Q ��     !  &T �i      *�     ��     :   lower �! ��     !  &T �9      *�     ��     :   	s2u_slice ��  q     v  J<         ��     5  &T �	         Y� � �  J< �� ��  q         ҩ �y �I        ֑ �a �1         ��     :   inp ֑ ��     !  &V ҩ      ��     ��     :   upper �a ��     !  &V �y      *�     ��     :   lower �1 ��     !  &V �I      *�     ��     :   	u2u_slice ��  q     v  J<         ��     5  &V �         J< � �  J< �� �  q         �� � 	Y )        �� q A           �     :   inp �� ��     !  &X ��     0�     ��     :   
old_bin_pt q ��     !  &X �      *�     ��     :   	new_width A ��     !  &Y 	Y      *�     ��     :   
new_bin_pt  ��     !  &Y )      *�     ��     :   s2s_cast  �  q     v  Y�          �     5  &X �         Y� � � �  Y� �� �  q         (� 0i 89 @	        ,� 4Q <! C�         O�     :   inp ,� $�     !  &[ (�      ��     $�     :   
old_bin_pt 4Q $�     !  &[ 0i      *�     $�     :   	new_width <! $�     !  &\ 89      *�     $�     :   
new_bin_pt C� $�     !  &\ @	      *�     $�     :   u2s_cast O�  q     v  Y�         O�     5  &[ G�         J< � � �  Y� $� K�  q         Wy _I g n�        [a c1 k r�         ~�     :   inp [a S�     !  &^ Wy     0�     S�     :   
old_bin_pt c1 S�     !  &^ _I      *�     S�     :   	new_width k S�     !  &_ g      *�     S�     :   
new_bin_pt r� S�     !  &_ n�      *�     S�     :   s2u_cast ~�  q     v  J<         ~�     5  &^ v�         Y� � � �  J< S� z�  q         �Y �) �� ��        �A � �� ��         �i     :   inp �A �q     !  &a �Y      ��     �q     :   
old_bin_pt � �q     !  &a �)      *�     �q     :   	new_width �� �q     !  &b ��      *�     �q     :   
new_bin_pt �� �q     !  &b ��      *�     �q     :   u2u_cast �i  q     v  J<         �i     5  &a ��         J< � � �  J< �q ��  q         �9 �	 �� ̩        �! �� �� Б         �I     :   inp �! �Q     !  &d �9      ��     �Q     :   
old_bin_pt �� �Q     !  &d �	      *�     �Q     :   	new_width �� �Q     !  &e ��      *�     �Q     :   
new_bin_pt Б �Q     !  &e ̩      *�     �Q     :   u2v_cast �I  q     v  �[         �I     5  &d �y         J< � � �  �[ �Q �a  q         � �� � ��        � �� �� �q         )     :   inp � �1     !  &g �     0�     �1     :   
old_bin_pt �� �1     !  &g ��      *�     �1     :   	new_width �� �1     !  &h �      *�     �1     :   
new_bin_pt �q �1     !  &h ��      *�     �1     :   s2v_cast )  q     v  �[         )     5  &g Y         Y� � � �  �[ �1 A  q         � � "� *i 29 :	 A�        � � &� .Q 6! =� E�         Qy     :   inp �      !  &j �      �          :   	old_width �      !  &j �      *�          :   
old_bin_pt &�      !  &j "�      *�          :   	old_arith .Q      !  &j *i      *�          :   	new_width 6!      !  &k 29      *�          :   
new_bin_pt =�      !  &k :	      *�          :   	new_arith E�      !  &k A�      *�          :   trunc Qy  q     v  �[         Qy     5  &j I�         �[ � � � � � �  �[  M�  q         YI a h� p� x� �Y �)        ]1 e l� t� |q �A �         ��     :   inp ]1 Ua     !  &m YI      �     Ua     :   	old_width e Ua     !  &m a      *�     Ua     :   
old_bin_pt l� Ua     !  &m h�      *�     Ua     :   	old_arith t� Ua     !  &n p�      *�     Ua     :   	new_width |q Ua     !  &n x�      *�     Ua     :   
new_bin_pt �A Ua     !  &n �Y      *�     Ua     :   	new_arith � Ua     !  &o �)      *�     Ua     :   round_towards_inf ��  q     v  �[         ��     5  &m ��         �[ � � � � � �  �[ Ua ��  q         �� �i �9 �	 �� Ʃ �y        �� �Q �! �� �� ʑ �a         �     :   inp �� ��     !  &p ��      �     ��     :   	old_width �Q ��     !  &p �i      *�     ��     :   
old_bin_pt �! ��     !  &p �9      *�     ��     :   	old_arith �� ��     !  &q �	      *�     ��     :   	new_width �� ��     !  &q ��      *�     ��     :   
new_bin_pt ʑ ��     !  &q Ʃ      *�     ��     :   	new_arith �a ��     !  &r �y      *�     ��     :   round_towards_even �  q     v  �[         �     5  &p �I         �[ � � � � � �  �[ �� �1  q         ��        ��         ��     :   width �� �     !  &s ��      *�     �     :   
max_signed ��  q     v  �[         ��     5  &s ��        �  �[ � �  q         �Y        A         �     :   width A �q     !  &t �Y      *�     �q     :   
min_signed �  q     v  �[         �     5  &t )        �  �[ �q 	  q         � � $i ,9 4	 ;� C�        �  � (Q 0! 7� ?� G�         SI     :   inp � �     !  &u �      �     �     :   	old_width  � �     !  &u �      *�     �     :   
old_bin_pt (Q �     !  &u $i      *�     �     :   	old_arith 0! �     !  &v ,9      *�     �     :   	new_width 7� �     !  &v 4	      *�     �     :   
new_bin_pt ?� �     !  &v ;�      *�     �     :   	new_arith G� �     !  &v C�      *�     �     :   saturation_arith SI  q     v  �[         SI     5  &u Ky         �[ � � � � � �  �[ � Oa  q         [ b� j� r� zY �) ��        _ f� n� vq ~A � ��         ��     :   inp _ W1     !  &x [      �     W1     :   	old_width f� W1     !  &x b�      *�     W1     :   
old_bin_pt n� W1     !  &x j�      *�     W1     :   	old_arith vq W1     !  &y r�      *�     W1     :   	new_width ~A W1     !  &y zY      *�     W1     :   
new_bin_pt � W1     !  &y �)      *�     W1     :   	new_arith �� W1     !  &y ��      *�     W1     :   
wrap_arith ��  q     v  �[         ��     5  &x ��         �[ � � � � � �  �[ W1 ��  q         �i �9        �Q �!         ��     :   a_bin_pt �Q ��     !  &{ �i      *�     ��     :   b_bin_pt �! ��     !  &{ �9      *�     ��     :   fractional_bits ��  q     v �         ��     5  &{ �	        � � � �� ��  q         �� �y �I �        đ �a �1 �         �     :   a_width đ ��     !  &| ��      *�     ��     :   a_bin_pt �a ��     !  &| �y      *�     ��     :   b_width �1 ��     !  &| �I      *�     ��     :   b_bin_pt � ��     !  &| �      *�     ��     :   integer_bits �  q     v �         �     5  &| ��        � � � � � �� ��  q         � �Y        �q �A         �     :   inp �q �     !  &~ �      �     �     :   	new_width �A �     !  &~ �Y      *�     �     :   sign_ext �  q     v  �[         �     5  &~ �)         �[ �  �[ �   q         � �        � �         &9     :   inp � 
�     !  &� �      �     
�     :   	new_width � 
�     !  &� �      *�     
�     :   zero_ext &9  q     v  �[         &9     5  &� i         �[ �  �[ 
� "Q  q         1� 9�        5� =�         Ia     v  ��         5�     :   inp 5� *!     !  &� 1�     .	     *!     :   	new_width =� *!     !  &� 9�      *�     *!     :   zero_ext Ia  q     v  �[         Ia     5  &� A�         FS �  �[ *! Ey  q         Q1 Y `�        U \� d�         pq     :   inp U MI     !  &� Q1      �     MI     :   	new_width \� MI     !  &� Y      *�     MI     :   arith d� MI     !  &� `�      *�     MI     :   
extend_MSB pq  q     v  �[         pq     5  &� h�         �[ � �  �[ MI l�  q         xA � �� �� ��        |) �� �� �� �i         �!     :   inp |) tY     !  &� xA      �     tY     :   	old_width �� tY     !  &� �      *�     tY     :   delta �� tY     !  &� ��      *�     tY     :   	new_arith �� tY     !  &� ��      *�     tY     :   	new_width �i tY     !  &� ��      *�     tY     :   align_input �!  q     v  �[         �!     5  &� �Q         �[ � � � �  �[ tY �9  q         �� ��        �� ��         �a     :   inp �� �	     !  &� ��      �     �	     :   	new_width �� �	     !  &� ��      *�     �	     :   pad_LSB �a  q     v  �[         �a     5  &� ��         �[ �  �[ �	 �y  q         �1 � ��        � �� �         �q     :   inp � �I     !  &� �1      �     �I     :   	new_width �� �I     !  &� �      *�     �I     :   arith � �I     !  &� ��      *�     �I     :   pad_LSB �q  q     v  �[         �q     5  &� �         �[ � �  �[ �I �  q         �A �        �)  �         �     :   L �) �Y     !  &� �A      *�     �Y     :   R  � �Y     !  &� �      *�     �Y     :   max �  q     v �         �     5  &� �        � � � �Y �  q         � Q        i  9         +�     :   L i �     !  &� �      *�     �     :   R  9 �     !  &� Q      *�     �     :   min +�  q     v �         +�     5  &� $!        � � � � (	  q         7� ?y        ;� Ca         O     v ��         ;�     :   left ;� /�     !  &� 7�     3�     /�     :   right Ca /�     !  &� ?y     3�     /�     T   = O  q     v  ��         O     5  &� GI        �� ��  �� /� K1  q         V� ^�        Z� b�         nY     :   inp Z� S     !  &� V�      A     S     :   width b� S     !  &� ^�      *�     S     :   boolean_to_signed nY  q     v  Y�         nY     5  &� f�         �� �  Y� S jq  q         v) }�        z ��         ��     :   inp z rA     !  &� v)      A     rA     :   width �� rA     !  &� }�      *�     rA     :   boolean_to_unsigned ��  q     v  J<         ��     5  &� ��         �� �  J< rA ��  q         �i        �Q         �	     :   inp �Q ��     !  &� �i      A     ��     :   boolean_to_vector �	  q     v  �[         �	     5  &� �9         ��  �[ �� �!  q         ��        ��         �y     :   inp �� ��     !  &� ��     .	     ��     :   std_logic_to_vector �y  q     v  �[         �y     5  &� ��         FS  �[ �� ��  q         �I � ��        �1 � ��         �     :   inp �1 �a     !  &� �I      *�     �a     :   width � �a     !  &� �      *�     �a     :   arith �� �a     !  &� ��      *�     �a     :   integer_to_std_logic_vector �  q     v  �[         �     5  &� ۹        � � �  �[ �a ߡ  q         �Y �)        �A �         �     :   inp �A �q     !  &� �Y      �     �q     :   arith � �q     !  &� �)      *�     �q     :   std_logic_vector_to_integer �  q     v �         �     5  &� ��         �[ � � �q ��  q         
�        �         9     :   inp � �     !  &� 
�     .	  [ �     :   std_logic_to_integer 9  q     v �         9     5  &� i         FS � � Q  q         "	 )� 1�        %� -� 5�         AI     :   inp %� !     !  &� "	     3�     !     :   width -� !     !  &� )�      *�     !     :   index 5� !     !  &� 1�      *�     !     :   &bin_string_element_to_std_logic_vector AI  q     v  �[         AI     5  &� 9y        �� � �  �[ ! =a  q         I        M         X�     :   inp M E1     !  &� I     3�     E1     :   bin_string_to_std_logic_vector X�  q     v  �[         X�     5  &� P�        ��  �[ E1 T�  q         `� hY        dq lA         w�     :   inp dq \�     !  &� `�     3�     \�     :   width lA \�     !  &� hY      *�     \�     :   hex_string_to_std_logic_vector w�  q     v  �[         w�     5  &� p)        �� �  �[ \� t  q         �        ��         �i     :   width �� {�     !  &� �      *�     {�     :   makeZeroBinStr �i  q     v ��         �i     5  &� ��        � �� {� ��  q         �9        �!         ��     :   inp �! �Q     !  &� �9      �     �Q     :   
and_reduce ��  q     v  ��         ��     5  &� �	         �[  FS �Q ��  q     %     �  �         �  �  Y ��     �   U/home/sean/SDR/Firmware/projects/chan_550_clean/sysgen/synth_model/chan_550_clean.vhd ��  �                conv_pkg       work      conv_pkg       work      standard       std      std_logic_1164       ieee      numeric_std       ieee