using System;
using UnityEngine;

namespace DefaultNamespace
{
    public class MovementPath : MonoBehaviour
    {
        [SerializeField] private Color _gizmoColor = Color.green;

        public Vector3[] GetPoints()
        {
            var points = new Vector3[transform.childCount];

            for (var ii = 0; ii < points.Length; ii++)
            {
                points[ii] = transform.GetChild(ii).position;
            }
            
            return points;
        }

        public float GetLength()
        {
            var points = GetPoints();
            var length = 0f;
            
            for (var ii = 0; ii < points.Length - 1; ii++)
            {
                var current = points[ii];
                var next = points[ii + 1];

                length += Vector3.Distance(current, next);
            }

            return length;
        }
        
        private void OnDrawGizmos()
        {
            Gizmos.color = _gizmoColor;
            
            for (var ii = 0; ii < transform.childCount - 1; ii++)
            {
                var currentPoint = transform.GetChild(ii);
                var nextPoint = transform.GetChild(ii + 1);
                
                Gizmos.DrawLine(currentPoint.position, nextPoint.position);
            }
        }
    }
}