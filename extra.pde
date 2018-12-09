//void advance(float t) {
//    //position.add(PVector.add(PVector.mult(velocity, t), PVector.mult(acceleration, 0.5 * t * t)));
//    //velocity.add(PVector.mult(acceleration, t));
    
//    PVector halfDeltaV = PVector.mult(acceleration, t * 0.5);
//    velocity.add(halfDeltaV);
//    position.add(PVector.mult(velocity, t));
//    velocity.add(halfDeltaV);
    
//  }




/*
  
  F_net = m a
  a = F_net / m
  
  m_1 v_1i + m_2 v_2i = m_1 v_1f + m_2 v_2f
  
  v_1f = (m_1 v_1i + m_2 v_2i - m_2 v_2f) / m_1
       = (m_1 v_1i + m_2 (v_2i - v_2f)) / m_1
       = v_1i + m_2 (v_2i - v_2f) / m_1
  
  
  
  
  
  */
